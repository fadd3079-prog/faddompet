import '../local/database/app_database.dart';
import '../local/seed/default_seed_data.dart';

class BootstrapRepository {
  const BootstrapRepository(this._database);

  final AppDatabase _database;

  Future<void> ensureSeeded() async {
    final now = DateTime.now();

    if (await _database.seedDao.walletCount() == 0) {
      await _database.seedDao.insertWallets(DefaultSeedData.wallets(now));
    }

    if (await _database.seedDao.categoryCount() == 0) {
      await _database.seedDao.insertCategories(DefaultSeedData.categories(now));
    }

    if (await _database.seedDao.settingsCount() == 0) {
      await _database.seedDao.insertSettings(DefaultSeedData.settings(now));
    }
  }
}
