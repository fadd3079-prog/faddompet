import 'package:drift/drift.dart';

import '../../core/enums/category_type.dart';
import '../local/database/app_database.dart';

class CategoryRepository {
  const CategoryRepository(this._database);

  final AppDatabase _database;

  Stream<List<CategoryEntry>> watchAll() {
    return _database.categoriesDao.watchAll();
  }

  Future<List<CategoryEntry>> getByTransactionType(String type) {
    return _database.categoriesDao.getByType(type);
  }

  Future<void> addCategory({
    required String name,
    required CategoryType type,
    required String groupName,
    required int colorValue,
  }) async {
    final now = DateTime.now();
    await _database.categoriesDao.add(
      CategoryEntriesCompanion.insert(
        name: name.trim(),
        type: type.value,
        groupName: groupName.trim().isEmpty ? 'Lainnya' : groupName.trim(),
        iconKey: 'category',
        colorValue: colorValue,
        isDefault: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateCategory(CategoryEntry category, String name) async {
    await _database.categoriesDao.updateEntry(
      category
          .copyWith(name: name.trim(), updatedAt: DateTime.now())
          .toCompanion(true),
    );
  }

  Future<String?> safeDeleteMessage(CategoryEntry category) async {
    if (category.isDefault) {
      return 'Kategori bawaan tidak bisa dihapus.';
    }

    final count = await _database.transactionsDao.countByCategory(category.id);
    if (count > 0) {
      return 'Kategori ini sudah dipakai di transaksi.';
    }

    return null;
  }
}
