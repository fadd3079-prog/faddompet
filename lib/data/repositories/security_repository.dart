import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecuritySettings {
  const SecuritySettings({
    required this.pinEnabled,
    required this.biometricEnabled,
    required this.autoLockMinutes,
    required this.pinLength,
  });

  final bool pinEnabled;
  final bool biometricEnabled;
  final int autoLockMinutes;
  final int pinLength;
}

class SecurityRepository {
  SecurityRepository({
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _pinHashKey = 'security_pin_hash';
  static const _pinSaltKey = 'security_pin_salt';
  static const _pinLengthKey = 'security_pin_length';
  static const _biometricKey = 'security_biometric_enabled';
  static const _autoLockKey = 'security_auto_lock_minutes';

  Future<SecuritySettings> loadSettings() async {
    final hash = await _storage.read(key: _pinHashKey);
    final biometric = await _storage.read(key: _biometricKey);
    final autoLock = await _storage.read(key: _autoLockKey);
    final pinLength = await _storage.read(key: _pinLengthKey);
    return SecuritySettings(
      pinEnabled: hash != null && hash.isNotEmpty,
      biometricEnabled: biometric == 'true',
      autoLockMinutes: int.tryParse(autoLock ?? '') ?? 1,
      pinLength: int.tryParse(pinLength ?? '') ?? 6,
    );
  }

  Future<void> savePin(String pin) async {
    _validatePin(pin);
    final salt = _salt();
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: _hash(pin, salt));
    await _storage.write(key: _pinLengthKey, value: pin.length.toString());
  }

  Future<bool> verifyPin(String pin) async {
    final hash = await _storage.read(key: _pinHashKey);
    final salt = await _storage.read(key: _pinSaltKey);
    if (hash == null || salt == null) return false;
    return _hash(pin, salt) == hash;
  }

  Future<void> disablePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _pinLengthKey);
    await _storage.delete(key: _biometricKey);
  }

  Future<void> setBiometricEnabled(bool value) async {
    final settings = await loadSettings();
    if (!settings.pinEnabled) {
      throw ArgumentError('Buat PIN terlebih dahulu.');
    }
    if (value && !await canUseBiometric()) {
      throw ArgumentError('Biometrik tidak tersedia di perangkat ini.');
    }
    await _storage.write(key: _biometricKey, value: value.toString());
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _storage.write(key: _autoLockKey, value: minutes.toString());
  }

  Future<bool> canUseBiometric() async {
    final supported = await _localAuth.isDeviceSupported();
    final canCheck = await _localAuth.canCheckBiometrics;
    return supported && canCheck;
  }

  Future<bool> unlockWithBiometric() async {
    if (!await canUseBiometric()) {
      throw ArgumentError('Biometrik tidak tersedia di perangkat ini.');
    }
    return _localAuth.authenticate(
      localizedReason: 'Buka FadDompet dengan biometrik',
      biometricOnly: true,
      persistAcrossBackgrounding: false,
    );
  }

  void _validatePin(String pin) {
    final valid = RegExp(r'^\d{4,6}$').hasMatch(pin);
    if (!valid) {
      throw ArgumentError('PIN harus berisi 4 sampai 6 angka.');
    }
  }

  String _salt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hash(String pin, String salt) {
    final input = utf8.encode('$salt:$pin');
    return sha256.convert(input).toString();
  }
}
