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
  connecting,    // Connexion et appairage BLE en cours
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
  final String? ssid;
  final String? wifiPassword;
  final String? errorMessage;
  final List<String> wifiNetworks;

  DeviceSetupModel({
    this.state = DeviceSetupState.scanning,
    this.devices = const [],
    this.selectedDevice,
    this.ssid,
    this.wifiPassword,
    this.errorMessage,
    this.wifiNetworks = const [],
  });

  DeviceSetupModel copyWith({
    DeviceSetupState? state,
    List<BluetoothEndpoint>? devices,
    BluetoothEndpoint? selectedDevice,
    String? ssid,
    String? wifiPassword,
    String? errorMessage,
    List<String>? wifiNetworks,
  }) {
    return DeviceSetupModel(
      state: state ?? this.state,
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
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
        state: DeviceSetupState.connecting,
      );

      final connected = await _bluetoothService.connect(device);
      
      if (connected) {
        // Wait for OS-level BLE pairing to complete
        // The pairing dialog will be shown by the OS
        // Wait for ESP32 to send "PAIRED" status
        
        if (device is RealBluetoothEndpoint) {
          final paired = await device.waitForPaired(
            timeout: const Duration(seconds: 30),
          );
          
          if (!paired) {
            state = state.copyWith(
              state: DeviceSetupState.error,
              errorMessage: 'Le jumelage Bluetooth a échoué ou a expiré',
            );
            return;
          }
          
          // Fetch available WiFi networks from the device
          final networks = await device.getAvailableWifiNetworks();
          
          state = state.copyWith(
            state: DeviceSetupState.selectWifi,
            wifiNetworks: networks,
          );
        } else {
          // Mock endpoint - just proceed
          await Future.delayed(const Duration(seconds: 1));
          state = state.copyWith(
            state: DeviceSetupState.selectWifi,
            wifiNetworks: ['Mock Network 1', 'Mock Network 2'],
          );
        }
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

  // PIN verification removed - using OS-level BLE pairing only

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
