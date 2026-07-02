import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:faddompet/data/repositories/security_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('verifies correct and incorrect PIN', () async {
    const storage = FlutterSecureStorage();
    final repository = SecurityRepository(storage: storage);

    await repository.savePin('123456');

    expect(await repository.verifyPin('123456'), isTrue);
    expect(await repository.verifyPin('000000'), isFalse);
  });

  test('stores salted hash instead of raw PIN', () async {
    const storage = FlutterSecureStorage();
    final repository = SecurityRepository(storage: storage);

    await repository.savePin('123456');

    final hash = await storage.read(key: 'security_pin_hash');
    final salt = await storage.read(key: 'security_pin_salt');

    expect(hash, isNotNull);
    expect(salt, isNotNull);
    expect(hash, isNot('123456'));
    expect(hash, isNot(contains('123456')));
  });

  test('disable PIN clears security state', () async {
    const storage = FlutterSecureStorage();
    final repository = SecurityRepository(storage: storage);

    await repository.savePin('123456');
    await repository.setAutoLockMinutes(15);
    await repository.registerFailedPinAttempt();
    await repository.disablePin();

    final settings = await repository.loadSettings();
    final attempts = await repository.loadPinAttemptState();

    expect(settings.pinEnabled, isFalse);
    expect(settings.biometricEnabled, isFalse);
    expect(settings.autoLockMinutes, 1);
    expect(attempts.failedAttempts, 0);
    expect(attempts.cooldownUntil, isNull);
  });

  test('starts cooldown after five failed attempts', () async {
    const storage = FlutterSecureStorage();
    final repository = SecurityRepository(storage: storage);

    for (var index = 0; index < 4; index++) {
      final state = await repository.registerFailedPinAttempt();
      expect(state.isCoolingDown, isFalse);
    }

    final cooldown = await repository.registerFailedPinAttempt();

    expect(cooldown.isCoolingDown, isTrue);
    expect(cooldown.remainingCooldown.inSeconds, greaterThan(0));
  });
}
