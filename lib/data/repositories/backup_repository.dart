import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../local/database/app_database.dart';
import '../local/seed/default_seed_data.dart';

class BackupRepository {
  const BackupRepository(this._database);

  final AppDatabase _database;

  Future<String> exportJson() async {
    final payload = await _backupPayload();
    final name =
        'faddompet-backup-${DateTime.now().millisecondsSinceEpoch}.json';
    final file = _xFile(
      name: name,
      content: const JsonEncoder.withIndent('  ').convert(payload),
      mimeType: 'application/json',
    );
    await Share.shareXFiles([file], text: 'Cadangan FadDompet');
    return name;
  }

  Future<String> exportCsv() async {
    final transactions = await _database.transactionsDao.getAll();
    final categories = await _database.categoriesDao.getAll();
    final wallets = await _database.walletsDao.getAll();
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final walletsById = {for (final wallet in wallets) wallet.id: wallet};

    final rows = [
      [
        'id',
        'type',
        'amount',
        'category',
        'wallet',
        'transfer_wallet',
        'date',
        'note',
      ],
      for (final transaction in transactions)
        [
          transaction.id,
          transaction.type,
          transaction.amount,
          categoriesById[transaction.categoryId]?.name ?? '',
          walletsById[transaction.walletId]?.name ?? '',
          walletsById[transaction.transferWalletId]?.name ?? '',
          transaction.date.toIso8601String(),
          transaction.note ?? '',
        ],
    ];

    final name =
        'faddompet-transaksi-${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = _xFile(
      name: name,
      content: csv.encode(rows),
      mimeType: 'text/csv',
    );
    await Share.shareXFiles([file], text: 'CSV transaksi FadDompet');
    return name;
  }

  Future<void> importJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) {
      return;
    }

    final raw = utf8.decode(bytes);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
      throw FormatException('File backup tidak valid.');
    }

    await _database.transaction(() async {
      await _database.backupDao.clearUserData();
      await _restore(decoded);
    });
  }

  Future<void> resetData() async {
    await _database.transaction(() async {
      await _database.backupDao.clearUserData();
      final now = DateTime.now();
      await _database.seedDao.insertWallets(DefaultSeedData.wallets(now));
      await _database.seedDao.insertCategories(DefaultSeedData.categories(now));
      await _database.seedDao.insertSettings(DefaultSeedData.settings(now));
    });
  }

  Future<Map<String, dynamic>> _backupPayload() async {
    final transactions = await _database.transactionsDao.getAll();
    final categories = await _database.categoriesDao.getAll();
    final wallets = await _database.walletsDao.getAll();
    final budgets = await _database.budgetsDao.getAll();
    final settings = await _database.appSettingsDao.getSettings();

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'transactions': transactions.map(_transactionToJson).toList(),
      'categories': categories.map(_categoryToJson).toList(),
      'wallets': wallets.map(_walletToJson).toList(),
      'budgets': budgets.map(_budgetToJson).toList(),
      'quick_templates': <Map<String, dynamic>>[],
      'app_settings': settings == null ? null : _settingsToJson(settings),
    };
  }

  XFile _xFile({
    required String name,
    required String content,
    required String mimeType,
  }) {
    return XFile.fromData(
      Uint8List.fromList(utf8.encode(content)),
      name: name,
      mimeType: mimeType,
    );
  }

  Future<void> _restore(Map<String, dynamic> payload) async {
    final now = DateTime.now();
    final wallets = _list(payload['wallets']);
    final categories = _list(payload['categories']);
    final transactions = _list(payload['transactions']);
    final budgets = _list(payload['budgets']);
    final settings = payload['app_settings'];

    if (wallets.isEmpty || categories.isEmpty) {
      throw FormatException('File backup tidak valid.');
    }

    await _database.seedDao.insertWallets([
      for (final item in wallets) _walletFromJson(item, now),
    ]);
    await _database.seedDao.insertCategories([
      for (final item in categories) _categoryFromJson(item, now),
    ]);

    for (final item in transactions) {
      await _database.transactionsDao.add(_transactionFromJson(item, now));
    }

    for (final item in budgets) {
      await _database.budgetsDao.add(_budgetFromJson(item, now));
    }

    await _database.seedDao.insertSettings(
      settings is Map<String, dynamic>
          ? _settingsFromJson(settings, now)
          : DefaultSeedData.settings(now),
    );
  }

  List<Map<String, dynamic>> _list(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) item,
    ];
  }

  Map<String, dynamic> _transactionToJson(TransactionEntry entry) => {
    'id': entry.id,
    'type': entry.type,
    'amount': entry.amount,
    'category_id': entry.categoryId,
    'wallet_id': entry.walletId,
    'transfer_wallet_id': entry.transferWalletId,
    'date': entry.date.toIso8601String(),
    'note': entry.note,
  };

  Map<String, dynamic> _categoryToJson(CategoryEntry entry) => {
    'id': entry.id,
    'name': entry.name,
    'type': entry.type,
    'group_name': entry.groupName,
    'icon_key': entry.iconKey,
    'color_value': entry.colorValue,
    'is_default': entry.isDefault,
    'is_archived': entry.isArchived,
  };

  Map<String, dynamic> _walletToJson(WalletEntry entry) => {
    'id': entry.id,
    'name': entry.name,
    'type': entry.type,
    'initial_balance': entry.initialBalance,
    'is_archived': entry.isArchived,
  };

  Map<String, dynamic> _budgetToJson(BudgetEntry entry) => {
    'id': entry.id,
    'category_id': entry.categoryId,
    'month': entry.month,
    'limit_amount': entry.limitAmount,
  };

  Map<String, dynamic> _settingsToJson(AppSettingEntry entry) => {
    'user_name': entry.userName,
    'currency': entry.currency,
    'theme_mode': entry.themeMode,
    'hide_balance': entry.hideBalance,
    'onboarding_completed': entry.onboardingCompleted,
  };

  TransactionEntriesCompanion _transactionFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return TransactionEntriesCompanion.insert(
      id: Value(item['id'] as int? ?? 0),
      type: item['type'] as String,
      amount: item['amount'] as int,
      walletId: item['wallet_id'] as int,
      categoryId: Value(item['category_id'] as int?),
      transferWalletId: Value(item['transfer_wallet_id'] as int?),
      date: DateTime.tryParse(item['date'] as String? ?? '') ?? now,
      note: Value(item['note'] as String?),
      createdAt: now,
      updatedAt: now,
    );
  }

  CategoryEntriesCompanion _categoryFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return CategoryEntriesCompanion.insert(
      id: Value(item['id'] as int? ?? 0),
      name: item['name'] as String,
      type: item['type'] as String,
      groupName: item['group_name'] as String,
      iconKey: item['icon_key'] as String? ?? 'category',
      colorValue: item['color_value'] as int? ?? 0xFF6B7280,
      isDefault: Value(item['is_default'] as bool? ?? false),
      isArchived: Value(item['is_archived'] as bool? ?? false),
      createdAt: now,
      updatedAt: now,
    );
  }

  WalletEntriesCompanion _walletFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return WalletEntriesCompanion.insert(
      id: Value(item['id'] as int? ?? 0),
      name: item['name'] as String,
      type: item['type'] as String,
      initialBalance: Value(item['initial_balance'] as int? ?? 0),
      isArchived: Value(item['is_archived'] as bool? ?? false),
      createdAt: now,
      updatedAt: now,
    );
  }

  BudgetEntriesCompanion _budgetFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return BudgetEntriesCompanion.insert(
      id: Value(item['id'] as int? ?? 0),
      categoryId: Value(item['category_id'] as int?),
      month: item['month'] as String,
      limitAmount: item['limit_amount'] as int,
      createdAt: now,
      updatedAt: now,
    );
  }

  AppSettingEntriesCompanion _settingsFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return AppSettingEntriesCompanion.insert(
      userName: Value(item['user_name'] as String?),
      currency: Value(item['currency'] as String? ?? 'IDR'),
      themeMode: Value(item['theme_mode'] as String? ?? 'system'),
      hideBalance: Value(item['hide_balance'] as bool? ?? false),
      onboardingCompleted: Value(item['onboarding_completed'] as bool? ?? true),
      createdAt: now,
      updatedAt: now,
    );
  }
}
