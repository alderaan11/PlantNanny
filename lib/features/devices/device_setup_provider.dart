import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/bluetooth_service.dart';
import '../../core/api_client_provider.dart';
import 'real_bluetooth_service.dart';
import 'package:plant_nanny_api/plant_nanny_api.dart';

/// Debug logger helper
void _log(String message) {
  if (kDebugMode) {
    print('[DeviceSetup] $message');
  }
}

/// Provider pour le service Bluetooth
final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  return RealBluetoothService();
});

/// États possibles du flux d'ajout d'appareil
enum DeviceSetupState {
  scanning,      // Scan BLE en cours
  selectDevice,  // Sélection de l'appareil
  connecting,    // Connexion BLE en cours
  enterPin,      // Saisie du code PIN affiché sur l'appareil
  selectWifi,    // Sélection du réseau WiFi
  enterWifiPass, // Saisie du mot de passe WiFi
  sending,       // Envoi des données
  waitingWifi,   // Attente de la connexion WiFi sur ESP32
  success,       // Succès
  error,         // Erreur
  wifiError,     // Erreur WiFi - peut réessayer
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
      _log('selectDevice: Starting connection to ${device.name}');
      state = state.copyWith(
        selectedDevice: device,
        state: DeviceSetupState.connecting,
      );

      final connected = await _bluetoothService.connect(device);
      _log('selectDevice: Connection result: $connected');
      
      if (connected) {
        // Connection established, now show PIN entry screen
        // User will enter the PIN displayed on the ESP32 screen
        _log('selectDevice: Transitioning to enterPin state');
        state = state.copyWith(state: DeviceSetupState.enterPin);
      } else {
        _log('selectDevice: Connection failed');
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Impossible de se connecter à l\'appareil',
        );
      }
    } catch (e) {
      _log('selectDevice error: $e');
      state = state.copyWith(
        state: DeviceSetupState.error,
        errorMessage: 'Erreur de connexion: $e',
      );
    }
  }

  /// Envoie le code PIN pour vérification
  Future<void> submitPin(String pin) async {
    try {
      _log('submitPin: Submitting PIN...');
      state = state.copyWith(
        pin: pin,
        state: DeviceSetupState.connecting,
      );

      final endpoint = state.selectedDevice;
      if (endpoint == null || endpoint is! RealBluetoothEndpoint) {
        _log('submitPin: No endpoint');
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Appareil non connecté',
        );
        return;
      }

      // Send PIN to ESP32 for verification
      final success = await endpoint.sendPin(pin);
      _log('submitPin: Send result: $success');
      if (!success) {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Échec de l\'envoi du code PIN',
        );
        return;
      }

      // Wait for PIN verification response from ESP32
      _log('submitPin: Waiting for verification response...');
      final response = await endpoint.waitForPinResult(
        timeout: const Duration(seconds: 10),
      );
      _log('submitPin: Response: $response');

      if (response == 'PIN_OK') {
        // PIN verified, fetch WiFi networks
        final networks = await endpoint.getAvailableWifiNetworks();
        
        state = state.copyWith(
          state: DeviceSetupState.selectWifi,
          wifiNetworks: networks,
        );
      } else if (response == 'PIN_INVALID') {
        state = state.copyWith(
          state: DeviceSetupState.enterPin,
          errorMessage: 'Code PIN incorrect',
        );
      } else {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Erreur de vérification du PIN: $response',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: DeviceSetupState.error,
        errorMessage: 'Erreur lors de la vérification du PIN: $e',
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

      final endpoint = state.selectedDevice;
      if (endpoint == null || endpoint is! RealBluetoothEndpoint) {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Appareil non connecté',
        );
        return;
      }

      final ssid = state.ssid;
      if (ssid == null || ssid.isEmpty) {
        state = state.copyWith(
          state: DeviceSetupState.error,
          errorMessage: 'Réseau WiFi non sélectionné',
        );
        return;
      }

      // Send WiFi credentials to ESP32
      await endpoint.sendWifiCredentials(ssid, password);
      
      // Wait for ESP32 to try connecting
      state = state.copyWith(state: DeviceSetupState.waitingWifi);
      
      // Wait for WiFi connection result from ESP32 (with polling fallback)
      final response = await endpoint.waitForWifiResult(
        timeout: const Duration(seconds: 45),
      );

      if (response == 'WIFI_CONFIGURED') {
        // WiFi configured, now get IP address and register with server
        await _registerDeviceWithServer();
      } else if (response == 'WIFI_FAILED') {
        // WiFi connection failed on ESP32 - allow retry
        state = state.copyWith(
          state: DeviceSetupState.wifiError,
          errorMessage: 'La connexion WiFi a échoué. Vérifiez le mot de passe.',
        );
      } else {
        state = state.copyWith(
          state: DeviceSetupState.wifiError,
          errorMessage: 'Réponse inattendue: $response',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: DeviceSetupState.wifiError,
        errorMessage: 'Erreur lors de l\'envoi des informations WiFi: $e',
      );
    }
  }

  /// Retry WiFi configuration with different credentials
  void retryWifiConfig() {
    state = state.copyWith(
      state: DeviceSetupState.selectWifi,
      errorMessage: null,
    );
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
        final serverDeviceId = response.data?.deviceId;
        if (serverDeviceId != null) {
          await endpoint.sendServerId(serverDeviceId);
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

  /// Retourne à l'étape de sélection d'appareil
  void backToDeviceSelection() {
    state = state.copyWith(state: DeviceSetupState.selectDevice);
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
