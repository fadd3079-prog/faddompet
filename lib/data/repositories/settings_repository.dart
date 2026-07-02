import 'package:drift/drift.dart';

import '../local/database/app_database.dart';

class SettingsRepository {
  const SettingsRepository(this._database);

  final AppDatabase _database;

  Stream<AppSettingEntry?> watchSettings() {
    return _database.appSettingsDao.watchSettings();
  }

  Future<AppSettingEntry?> getSettings() {
    return _database.appSettingsDao.getSettings();
  }

  Future<void> completeOnboarding({
    String? userName,
    Map<int, int> initialBalances = const {},
  }) async {
    final now = DateTime.now();
    final settings = await _database.appSettingsDao.getSettings();
    final wallets = await _database.walletsDao.getAll();

    await _database.transaction(() async {
      for (final wallet in wallets) {
        final balance = initialBalances[wallet.id];
        if (balance != null) {
          await _database.walletsDao.updateEntry(
            wallet
                .copyWith(initialBalance: balance, updatedAt: now)
                .toCompanion(true),
          );
        }
      }

      if (settings != null) {
        await _database.appSettingsDao.updateSettings(
          settings
              .copyWith(
                userName: Value(
                  userName?.trim().isEmpty ?? true ? null : userName!.trim(),
                ),
                onboardingCompleted: true,
                updatedAt: now,
              )
              .toCompanion(true),
        );
      }
    });
  }

  Future<void> setThemeMode(String value) async {
    final settings = await _database.appSettingsDao.getSettings();
    if (settings == null) return;

    await _database.appSettingsDao.updateSettings(
      settings
          .copyWith(themeMode: value, updatedAt: DateTime.now())
          .toCompanion(true),
    );
  }

  Future<void> setHideBalance(bool value) async {
    final settings = await _database.appSettingsDao.getSettings();
    if (settings == null) return;

    await _database.appSettingsDao.updateSettings(
      settings
          .copyWith(hideBalance: value, updatedAt: DateTime.now())
          .toCompanion(true),
    );
  }
}
