import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/bluetooth_service.dart';
import 'fake_bluetooth_service.dart';

/// Provider pour le service Bluetooth
final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  return FakeBluetoothService();
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

  DeviceSetupModel({
    this.state = DeviceSetupState.scanning,
    this.devices = const [],
    this.selectedDevice,
    this.pin,
    this.ssid,
    this.wifiPassword,
    this.errorMessage,
  });

  DeviceSetupModel copyWith({
    DeviceSetupState? state,
    List<BluetoothEndpoint>? devices,
    BluetoothEndpoint? selectedDevice,
    String? pin,
    String? ssid,
    String? wifiPassword,
    String? errorMessage,
  }) {
    return DeviceSetupModel(
      state: state ?? this.state,
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      pin: pin ?? this.pin,
      ssid: ssid ?? this.ssid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier pour gérer le flux d'ajout d'appareil
class DeviceSetupNotifier extends StateNotifier<DeviceSetupModel> {
  final BluetoothService _bluetoothService;

  DeviceSetupNotifier(this._bluetoothService) : super(DeviceSetupModel()) {
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
        state = state.copyWith(state: DeviceSetupState.enterPin);
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

      await state.selectedDevice?.send('PIN:$pin');
      final response = await state.selectedDevice?.recv(
        timeout: const Duration(seconds: 5),
      );

      if (response == 'PIN_OK') {
        state = state.copyWith(state: DeviceSetupState.selectWifi);
      } else {
        state = state.copyWith(
          state: DeviceSetupState.error,
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
        timeout: const Duration(seconds: 5),
      );

      if (response == 'WIFI_CONFIGURED') {
        state = state.copyWith(state: DeviceSetupState.success);
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
  return DeviceSetupNotifier(bluetoothService);
});
