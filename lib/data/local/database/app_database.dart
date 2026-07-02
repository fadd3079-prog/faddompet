import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

@DataClassName('TransactionEntry')
class TransactionEntries extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text().withLength(min: 1, max: 16)();
  IntColumn get amount => integer()();
  IntColumn get categoryId =>
      integer().nullable().references(CategoryEntries, #id)();
  IntColumn get walletId => integer().references(WalletEntries, #id)();
  IntColumn get transferWalletId =>
      integer().nullable().references(WalletEntries, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('CategoryEntry')
class CategoryEntries extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get type => text().withLength(min: 1, max: 16)();
  TextColumn get groupName => text().withLength(min: 1, max: 80)();
  TextColumn get iconKey => text().withLength(min: 1, max: 80)();
  IntColumn get colorValue => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('WalletEntry')
class WalletEntries extends Table {
  @override
  String get tableName => 'wallets';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get type => text().withLength(min: 1, max: 24)();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('BudgetEntry')
class BudgetEntries extends Table {
  @override
  String get tableName => 'budgets';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().nullable().references(CategoryEntries, #id)();
  TextColumn get month => text().withLength(min: 7, max: 7)();
  IntColumn get limitAmount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('QuickTemplateEntry')
class QuickTemplateEntries extends Table {
  @override
  String get tableName => 'quick_templates';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 80)();
  TextColumn get transactionType => text().withLength(min: 1, max: 16)();
  IntColumn get defaultAmount => integer().nullable()();
  IntColumn get categoryId =>
      integer().nullable().references(CategoryEntries, #id)();
  IntColumn get walletId =>
      integer().nullable().references(WalletEntries, #id)();
  TextColumn get iconKey => text().withLength(min: 1, max: 80)();
  IntColumn get colorValue => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('AppSettingEntry')
class AppSettingEntries extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get userName => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get hideBalance => boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftAccessor(
  tables: [
    TransactionEntries,
    CategoryEntries,
    WalletEntries,
    BudgetEntries,
    QuickTemplateEntries,
    AppSettingEntries,
  ],
)
class SeedDao extends DatabaseAccessor<AppDatabase> with _$SeedDaoMixin {
  SeedDao(super.db);

  Future<int> walletCount() =>
      select(walletEntries).get().then((v) => v.length);
  Future<int> categoryCount() =>
      select(categoryEntries).get().then((v) => v.length);
  Future<int> settingsCount() =>
      select(appSettingEntries).get().then((v) => v.length);
  Future<void> insertWallets(List<WalletEntriesCompanion> values) async {
    await batch((batch) => batch.insertAll(walletEntries, values));
  }

  Future<void> insertCategories(List<CategoryEntriesCompanion> values) async {
    await batch((batch) => batch.insertAll(categoryEntries, values));
  }

  Future<void> insertQuickTemplates(
    List<QuickTemplateEntriesCompanion> values,
  ) async {
    await batch((batch) => batch.insertAll(quickTemplateEntries, values));
  }

  Future<void> insertSettings(AppSettingEntriesCompanion value) {
    return into(appSettingEntries).insert(value);
  }
}

@DriftAccessor(tables: [TransactionEntries])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<TransactionEntry>> watchAll() {
    return (select(transactionEntries)..orderBy([
          (table) =>
              OrderingTerm(expression: table.date, mode: OrderingMode.desc),
          (table) => OrderingTerm(
            expression: table.createdAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  Future<List<TransactionEntry>> getAll() {
    return (select(transactionEntries)..orderBy([
          (table) =>
              OrderingTerm(expression: table.date, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<TransactionEntry?> getById(int id) {
    return (select(
      transactionEntries,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> add(TransactionEntriesCompanion entry) {
    return into(transactionEntries).insert(entry);
  }

  Future<void> updateEntry(TransactionEntriesCompanion entry) {
    return update(transactionEntries).replace(entry);
  }

  Future<int> deleteById(int id) {
    return (delete(
      transactionEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<int> countByWallet(int walletId) {
    return (select(transactionEntries)..where(
          (table) =>
              table.walletId.equals(walletId) |
              table.transferWalletId.equals(walletId),
        ))
        .get()
        .then((value) => value.length);
  }

  Future<int> countByCategory(int categoryId) {
    return (select(transactionEntries)
          ..where((table) => table.categoryId.equals(categoryId)))
        .get()
        .then((value) => value.length);
  }
}

@DriftAccessor(tables: [CategoryEntries])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<CategoryEntry>> watchAll() {
    return (select(categoryEntries)..orderBy([
          (table) => OrderingTerm(expression: table.groupName),
          (table) => OrderingTerm(expression: table.name),
        ]))
        .watch();
  }

  Future<List<CategoryEntry>> getAll() => select(categoryEntries).get();

  Future<List<CategoryEntry>> getByType(String type) {
    return (select(categoryEntries)
          ..where(
            (table) =>
                (table.type.equals(type) | table.type.equals('both')) &
                table.isArchived.equals(false),
          )
          ..orderBy([
            (table) => OrderingTerm(expression: table.groupName),
            (table) => OrderingTerm(expression: table.name),
          ]))
        .get();
  }

  Future<int> add(CategoryEntriesCompanion entry) {
    return into(categoryEntries).insert(entry);
  }

  Future<void> updateEntry(CategoryEntriesCompanion entry) {
    return update(categoryEntries).replace(entry);
  }

  Future<int> deleteById(int id) {
    return (delete(
      categoryEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<int> countDuplicate({
    required String name,
    required String type,
    required String groupName,
    int? exceptId,
  }) {
    final query = select(categoryEntries)
      ..where(
        (table) =>
            table.name.lower().equals(name.toLowerCase()) &
            table.type.equals(type) &
            table.groupName.lower().equals(groupName.toLowerCase()),
      );
    if (exceptId != null) {
      query.where((table) => table.id.equals(exceptId).not());
    }
    return query.get().then((value) => value.length);
  }
}

@DriftAccessor(tables: [WalletEntries])
class WalletsDao extends DatabaseAccessor<AppDatabase> with _$WalletsDaoMixin {
  WalletsDao(super.db);

  Stream<List<WalletEntry>> watchAll() {
    return (select(
      walletEntries,
    )..orderBy([(table) => OrderingTerm(expression: table.id)])).watch();
  }

  Future<List<WalletEntry>> getAll() => select(walletEntries).get();

  Future<int> countDuplicate({required String name, int? exceptId}) {
    final query = select(walletEntries)
      ..where((table) => table.name.lower().equals(name.toLowerCase()));
    if (exceptId != null) {
      query.where((table) => table.id.equals(exceptId).not());
    }
    return query.get().then((value) => value.length);
  }

  Future<int> add(WalletEntriesCompanion entry) {
    return into(walletEntries).insert(entry);
  }

  Future<void> updateEntry(WalletEntriesCompanion entry) {
    return update(walletEntries).replace(entry);
  }

  Future<int> deleteById(int id) {
    return (delete(walletEntries)..where((table) => table.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [BudgetEntries])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Stream<List<BudgetEntry>> watchAll() {
    return (select(budgetEntries)..orderBy([
          (table) =>
              OrderingTerm(expression: table.month, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<List<BudgetEntry>> getAll() => select(budgetEntries).get();

  Future<BudgetEntry?> getById(int id) {
    return (select(
      budgetEntries,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> countDuplicate({
    required String month,
    required int? categoryId,
    int? exceptId,
  }) {
    final query = select(budgetEntries)
      ..where((table) {
        final categoryExpression = categoryId == null
            ? table.categoryId.isNull()
            : table.categoryId.equals(categoryId);
        return table.month.equals(month) & categoryExpression;
      });
    if (exceptId != null) {
      query.where((table) => table.id.equals(exceptId).not());
    }
    return query.get().then((value) => value.length);
  }

  Future<int> add(BudgetEntriesCompanion entry) {
    return into(budgetEntries).insert(entry);
  }

  Future<void> updateEntry(BudgetEntriesCompanion entry) {
    return update(budgetEntries).replace(entry);
  }

  Future<int> deleteById(int id) {
    return (delete(budgetEntries)..where((table) => table.id.equals(id))).go();
  }

  Future<int> deleteByMonth(String month) {
    return (delete(
      budgetEntries,
    )..where((table) => table.month.equals(month))).go();
  }
}

@DriftAccessor(tables: [AppSettingEntries])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Stream<AppSettingEntry?> watchSettings() {
    return (select(appSettingEntries)..limit(1)).watchSingleOrNull();
  }

  Future<AppSettingEntry?> getSettings() {
    return (select(appSettingEntries)..limit(1)).getSingleOrNull();
  }

  Future<void> updateSettings(AppSettingEntriesCompanion entry) {
    return update(appSettingEntries).replace(entry);
  }
}

@DriftAccessor(
  tables: [
    TransactionEntries,
    CategoryEntries,
    WalletEntries,
    BudgetEntries,
    QuickTemplateEntries,
    AppSettingEntries,
  ],
)
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.db);

  Future<void> clearUserData() async {
    await transaction(() async {
      await delete(transactionEntries).go();
      await delete(budgetEntries).go();
      await delete(quickTemplateEntries).go();
      await delete(categoryEntries).go();
      await delete(walletEntries).go();
      await delete(appSettingEntries).go();
    });
  }
}

@DriftDatabase(
  tables: [
    TransactionEntries,
    CategoryEntries,
    WalletEntries,
    BudgetEntries,
    QuickTemplateEntries,
    AppSettingEntries,
  ],
  daos: [
    SeedDao,
    TransactionsDao,
    CategoriesDao,
    WalletsDao,
    BudgetsDao,
    AppSettingsDao,
    BackupDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'faddompet',
          web: kIsWeb
              ? DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                )
              : null,
        ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(walletEntries, walletEntries.isArchived);
          await m.addColumn(categoryEntries, categoryEntries.isArchived);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
