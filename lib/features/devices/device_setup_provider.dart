import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/bluetooth_service.dart';
import '../../core/api_client_provider.dart';
import 'real_bluetooth_service.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

/// Provider pour le service Bluetooth
final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  return RealBluetoothService();
});

/// États possibles du flux d'ajout d'appareil
enum DeviceSetupState {
  scanning,      // Scan BLE en cours
  selectDevice,  // Sélection de l'appareil
  enterPin,      // Saisie du code PIN
  selectWifi,    // Sélection du réseau WiFi
  enterWifiPass, // Saisie du mot de passe WiFi
  sending,       // Envoi des données
  success,       // Succès
  error,         // Erreur
}

/// État de la configuration de l'appareil
class DeviceSetupModel {
  final DeviceSetupState state;
  final List<BluetoothEndpoint> devices;
  final BluetoothEndpoint? selectedDevice;
  final String? pin;
  final String? ssid;
  final String? wifiPassword;
  final String? errorMessage;
  final List<String> wifiNetworks;

  DeviceSetupModel({
    this.state = DeviceSetupState.scanning,
    this.devices = const [],
    this.selectedDevice,
    this.pin,
    this.ssid,
    this.wifiPassword,
    this.errorMessage,
    this.wifiNetworks = const [],
  });

  DeviceSetupModel copyWith({
    DeviceSetupState? state,
    List<BluetoothEndpoint>? devices,
    BluetoothEndpoint? selectedDevice,
    String? pin,
    String? ssid,
    String? wifiPassword,
    String? errorMessage,
    List<String>? wifiNetworks,
  }) {
    return DeviceSetupModel(
      state: state ?? this.state,
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      pin: pin ?? this.pin,
      ssid: ssid ?? this.ssid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      errorMessage: errorMessage ?? this.errorMessage,
      wifiNetworks: wifiNetworks ?? this.wifiNetworks,
    );
  }
}

/// Notifier pour gérer le flux d'ajout d'appareil
class DeviceSetupNotifier extends StateNotifier<DeviceSetupModel> {
  final BluetoothService _bluetoothService;
  final PlantNannyApi _api;

  DeviceSetupNotifier(this._bluetoothService, this._api) : super(DeviceSetupModel()) {
    _startScan();
  }

  /// Lance le scan Bluetooth
  Future<void> _startScan() async {
    try {
      state = state.copyWith(state: DeviceSetupState.scanning);
      final devices = await _bluetoothService.findNearEndpoints();
      
      if (devices.isEmpty) {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Aucun appareil trouvé',
        );
      } else {
        state = state.copyWith(
          state: DeviceSetupState.selectDevice,
          devices: devices,
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: DeviceSetupState.error,
        errorMessage: 'Erreur lors du scan: $e',
      );
    }
  }

  /// Relance le scan
  void rescan() {
    _startScan();
  }

  /// Sélectionne un appareil et se connecte
  Future<void> selectDevice(BluetoothEndpoint device) async {
    try {
      state = state.copyWith(
        selectedDevice: device,
        state: DeviceSetupState.scanning,
      );

      final connected = await _bluetoothService.connect(device);
      
      if (connected) {
        // Go to PIN entry for verification
        state = state.copyWith(
          state: DeviceSetupState.enterPin,
        );
      } else {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Impossible de se connecter à l\'appareil',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: DeviceSetupState.error,
        errorMessage: 'Erreur de connexion: $e',
      );
    }
  }

  /// Valide le code PIN
  Future<void> submitPin(String pin) async {
    try {
      state = state.copyWith(
        pin: pin,
        state: DeviceSetupState.sending,
      );

      final device = state.selectedDevice;
      bool pinValid = false;
      
      if (device is RealBluetoothEndpoint) {
        // Use dedicated verifyPin method
        pinValid = await device.verifyPin(pin);
      } else {
        // Fallback for mock devices
        await device?.send('PIN:$pin');
        final response = await device?.recv(
          timeout: const Duration(seconds: 5),
        );
        pinValid = response == 'PIN_OK';
      }

      if (pinValid) {
        // Fetch available WiFi networks from the device
        List<String> networks = [];
        if (device is RealBluetoothEndpoint) {
          // Wait a moment for ESP32 to scan networks
          await Future.delayed(const Duration(seconds: 2));
          networks = await device.getAvailableWifiNetworks();
        }
        
        state = state.copyWith(
          state: DeviceSetupState.selectWifi,
          wifiNetworks: networks,
        );
      } else {
        state = state.copyWith(
          state: DeviceSetupState.enterPin,
          errorMessage: 'Code PIN invalide',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: DeviceSetupState.error,
        errorMessage: 'Erreur lors de l\'envoi du PIN: $e',
      );
    }
  }

  /// Sélectionne un réseau WiFi
  void selectWifi(String ssid) {
    state = state.copyWith(
      ssid: ssid,
      state: DeviceSetupState.enterWifiPass,
    );
  }

  /// Envoie les informations WiFi
  Future<void> submitWifiCredentials(String password) async {
    try {
      state = state.copyWith(
        wifiPassword: password,
        state: DeviceSetupState.sending,
      );

      final wifiData = 'WIFI:${state.ssid}:$password';
      await state.selectedDevice?.send(wifiData);
      
      final response = await state.selectedDevice?.recv(
        timeout: const Duration(seconds: 30),
      );

      if (response == 'WIFI_CONFIGURED') {
        // WiFi configured, now get IP address and register with server
        await _registerDeviceWithServer();
      } else {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Erreur lors de la configuration WiFi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: DeviceSetupState.error,
        errorMessage: 'Erreur lors de l\'envoi des informations WiFi: $e',
      );
    }
  }

  /// Register the device with the server after WiFi config
  Future<void> _registerDeviceWithServer() async {
    try {
      final endpoint = state.selectedDevice;
      if (endpoint == null || endpoint is! RealBluetoothEndpoint) {
        state = state.copyWith(state: DeviceSetupState.success);
        return;
      }

      // Get IP address from ESP32
      final ipAddress = await endpoint.waitForIpAddress(timeout: const Duration(seconds: 15));
      
      // Get device ID (used as pairing code)
      final deviceId = await endpoint.getDeviceId();
      
      if (deviceId == null) {
        // No device ID available, still succeed but without server registration
        state = state.copyWith(state: DeviceSetupState.success);
        return;
      }

      // Register device with server
      try {
        final registerRequest = RegisterDeviceRequest((b) => b
          ..pairingCode = deviceId
          ..name = endpoint.name ?? 'PlantNanny Device'
          ..ipAddress = ipAddress
        );

        final response = await _api.getDevicesApi().handlersV1DevicesRegisterPost(
          registerDeviceRequest: registerRequest,
        );

        // Send server-assigned device ID back to ESP32
        if (response.data?.deviceId != null) {
          await endpoint.sendServerId(response.data!.deviceId!);
        }
      } catch (apiError) {
        // API error - device may already be registered, continue anyway
        // Log the error but don't fail the setup
      }

      state = state.copyWith(state: DeviceSetupState.success);
    } catch (e) {
      // Registration failed, but WiFi is configured so still succeed
      state = state.copyWith(state: DeviceSetupState.success);
    }
  }

  /// Retourne à l'étape de sélection du WiFi
  void backToWifiSelection() {
    state = state.copyWith(state: DeviceSetupState.selectWifi);
  }

  /// Retourne à l'étape de saisie du PIN
  void backToPinEntry() {
    state = state.copyWith(state: DeviceSetupState.enterPin);
  }

  /// Reset l'état
  void reset() {
    state = DeviceSetupModel();
    _startScan();
  }
}

/// Provider pour le notifier
final deviceSetupProvider = StateNotifierProvider<DeviceSetupNotifier, DeviceSetupModel>((ref) {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  final api = ref.watch(apiClientProvider);
  return DeviceSetupNotifier(bluetoothService, api);
});
