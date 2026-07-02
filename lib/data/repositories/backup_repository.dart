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
    final preview = await pickImportPreview();
    if (preview == null) return;
    await restoreImport(preview);
  }

  Future<BackupImportPreview?> pickImportPreview() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) {
      return null;
    }

    final raw = utf8.decode(bytes);
    final payload = _decodeAndValidate(raw);
    return BackupImportPreview(
      payload: payload,
      transactions: _requiredList(payload, 'transactions').length,
      wallets: _requiredList(payload, 'wallets').length,
      categories: _requiredList(payload, 'categories').length,
      budgets: _requiredList(payload, 'budgets').length,
    );
  }

  Future<void> restoreImport(BackupImportPreview preview) async {
    await _database.transaction(() async {
      await _database.backupDao.clearUserData();
      await _restore(preview.payload);
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
    final wallets = _requiredList(payload, 'wallets');
    final categories = _requiredList(payload, 'categories');
    final transactions = _requiredList(payload, 'transactions');
    final budgets = _requiredList(payload, 'budgets');
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

  Map<String, dynamic> _decodeAndValidate(String raw) {
    final decoded = _map(jsonDecode(raw));
    if (decoded['version'] != 1) {
      throw FormatException('File cadangan tidak valid.');
    }

    final wallets = _requiredList(decoded, 'wallets');
    final categories = _requiredList(decoded, 'categories');
    final transactions = _requiredList(decoded, 'transactions');
    final budgets = _requiredList(decoded, 'budgets');
    final settings = decoded['app_settings'];

    if (wallets.isEmpty || categories.isEmpty) {
      throw FormatException('File cadangan tidak valid.');
    }

    final walletIds = _validateWallets(wallets);
    final categoryTypes = _validateCategories(categories);
    _validateTransactions(transactions, walletIds, categoryTypes);
    _validateBudgets(budgets, categoryTypes.keys.toSet());
    if (settings != null) _validateSettings(_map(settings));

    return decoded;
  }

  List<Map<String, dynamic>> _requiredList(
    Map<String, dynamic> payload,
    String key,
  ) {
    final value = payload[key];
    if (value is! List) throw FormatException('File cadangan tidak valid.');
    return [for (final item in value) _map(item)];
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is! Map) throw FormatException('File cadangan tidak valid.');
    final mapped = {
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
    if (mapped.length != value.length) {
      throw FormatException('File cadangan tidak valid.');
    }
    return mapped;
  }

  Set<int> _validateWallets(List<Map<String, dynamic>> wallets) {
    final ids = <int>{};
    const validTypes = {'cash', 'ewallet', 'bank', 'savings'};
    for (final item in wallets) {
      final id = _requiredId(item, 'id');
      if (!ids.add(id)) throw FormatException('File cadangan tidak valid.');
      _requiredString(item, 'name');
      _requiredString(item, 'type', allowed: validTypes);
      _optionalInt(item, 'initial_balance');
      _optionalBool(item, 'is_archived');
    }
    return ids;
  }

  Map<int, String> _validateCategories(List<Map<String, dynamic>> categories) {
    final values = <int, String>{};
    const validTypes = {'income', 'expense', 'both'};
    for (final item in categories) {
      final id = _requiredId(item, 'id');
      if (values.containsKey(id)) {
        throw FormatException('File cadangan tidak valid.');
      }
      _requiredString(item, 'name');
      final type = _requiredString(item, 'type', allowed: validTypes);
      _requiredString(item, 'group_name');
      _optionalString(item, 'icon_key');
      _requiredInt(item, 'color_value');
      _optionalBool(item, 'is_default');
      _optionalBool(item, 'is_archived');
      values[id] = type;
    }
    return values;
  }

  void _validateTransactions(
    List<Map<String, dynamic>> transactions,
    Set<int> walletIds,
    Map<int, String> categoryTypes,
  ) {
    final ids = <int>{};
    const validTypes = {'income', 'expense', 'transfer'};
    for (final item in transactions) {
      final id = _requiredId(item, 'id');
      if (!ids.add(id)) throw FormatException('File cadangan tidak valid.');
      final type = _requiredString(item, 'type', allowed: validTypes);
      final amount = _requiredInt(item, 'amount');
      if (amount <= 0) throw FormatException('File cadangan tidak valid.');
      final walletId = _requiredId(item, 'wallet_id');
      if (!walletIds.contains(walletId)) {
        throw FormatException('File cadangan tidak valid.');
      }
      final categoryId = _optionalId(item, 'category_id');
      final transferWalletId = _optionalId(item, 'transfer_wallet_id');
      if (categoryId != null && !categoryTypes.containsKey(categoryId)) {
        throw FormatException('File cadangan tidak valid.');
      }
      if (type == 'transfer') {
        if (transferWalletId == null ||
            !walletIds.contains(transferWalletId) ||
            transferWalletId == walletId) {
          throw FormatException('File cadangan tidak valid.');
        }
      } else {
        if (categoryId == null) {
          throw FormatException('File cadangan tidak valid.');
        }
        if (transferWalletId != null && !walletIds.contains(transferWalletId)) {
          throw FormatException('File cadangan tidak valid.');
        }
        final categoryType = categoryTypes[categoryId]!;
        if (categoryType != type && categoryType != 'both') {
          throw FormatException('File cadangan tidak valid.');
        }
      }
      _requiredDate(item, 'date');
      _optionalString(item, 'note');
    }
  }

  void _validateBudgets(
    List<Map<String, dynamic>> budgets,
    Set<int> categoryIds,
  ) {
    final ids = <int>{};
    final keys = <String>{};
    for (final item in budgets) {
      final id = _requiredId(item, 'id');
      if (!ids.add(id)) throw FormatException('File cadangan tidak valid.');
      final categoryId = _optionalId(item, 'category_id');
      if (categoryId != null && !categoryIds.contains(categoryId)) {
        throw FormatException('File cadangan tidak valid.');
      }
      final month = _requiredString(item, 'month');
      if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(month)) {
        throw FormatException('File cadangan tidak valid.');
      }
      final limit = _requiredInt(item, 'limit_amount');
      if (limit <= 0) throw FormatException('File cadangan tidak valid.');
      final key = '$month:${categoryId ?? 'total'}';
      if (!keys.add(key)) throw FormatException('File cadangan tidak valid.');
    }
  }

  void _validateSettings(Map<String, dynamic> item) {
    _optionalString(item, 'user_name');
    _optionalString(item, 'currency');
    _optionalString(
      item,
      'theme_mode',
      allowed: const {'system', 'light', 'dark'},
    );
    _optionalBool(item, 'hide_balance');
    _optionalBool(item, 'onboarding_completed');
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
      id: Value(_requiredId(item, 'id')),
      type: _requiredString(item, 'type'),
      amount: _requiredInt(item, 'amount'),
      walletId: _requiredId(item, 'wallet_id'),
      categoryId: Value(_optionalId(item, 'category_id')),
      transferWalletId: Value(_optionalId(item, 'transfer_wallet_id')),
      date: _requiredDate(item, 'date'),
      note: Value(_optionalString(item, 'note')),
      createdAt: now,
      updatedAt: now,
    );
  }

  CategoryEntriesCompanion _categoryFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return CategoryEntriesCompanion.insert(
      id: Value(_requiredId(item, 'id')),
      name: _requiredString(item, 'name'),
      type: _requiredString(item, 'type'),
      groupName: _requiredString(item, 'group_name'),
      iconKey: _optionalString(item, 'icon_key') ?? 'category',
      colorValue: _requiredInt(item, 'color_value'),
      isDefault: Value(_optionalBool(item, 'is_default') ?? false),
      isArchived: Value(_optionalBool(item, 'is_archived') ?? false),
      createdAt: now,
      updatedAt: now,
    );
  }

  WalletEntriesCompanion _walletFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return WalletEntriesCompanion.insert(
      id: Value(_requiredId(item, 'id')),
      name: _requiredString(item, 'name'),
      type: _requiredString(item, 'type'),
      initialBalance: Value(_optionalInt(item, 'initial_balance') ?? 0),
      isArchived: Value(_optionalBool(item, 'is_archived') ?? false),
      createdAt: now,
      updatedAt: now,
    );
  }

  BudgetEntriesCompanion _budgetFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return BudgetEntriesCompanion.insert(
      id: Value(_requiredId(item, 'id')),
      categoryId: Value(_optionalId(item, 'category_id')),
      month: _requiredString(item, 'month'),
      limitAmount: _requiredInt(item, 'limit_amount'),
      createdAt: now,
      updatedAt: now,
    );
  }

  AppSettingEntriesCompanion _settingsFromJson(
    Map<String, dynamic> item,
    DateTime now,
  ) {
    return AppSettingEntriesCompanion.insert(
      userName: Value(_optionalString(item, 'user_name')),
      currency: Value(_optionalString(item, 'currency') ?? 'IDR'),
      themeMode: Value(_optionalString(item, 'theme_mode') ?? 'system'),
      hideBalance: Value(_optionalBool(item, 'hide_balance') ?? false),
      onboardingCompleted: Value(
        _optionalBool(item, 'onboarding_completed') ?? true,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  int _requiredId(Map<String, dynamic> item, String key) {
    final value = _requiredInt(item, key);
    if (value <= 0) throw FormatException('File cadangan tidak valid.');
    return value;
  }

  int _requiredInt(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value is! int) throw FormatException('File cadangan tidak valid.');
    return value;
  }

  int? _optionalInt(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return null;
    if (value is! int) throw FormatException('File cadangan tidak valid.');
    return value;
  }

  int? _optionalId(Map<String, dynamic> item, String key) {
    final value = _optionalInt(item, key);
    if (value == null) return null;
    if (value <= 0) throw FormatException('File cadangan tidak valid.');
    return value;
  }

  String _requiredString(
    Map<String, dynamic> item,
    String key, {
    Set<String>? allowed,
  }) {
    final value = item[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('File cadangan tidak valid.');
    }
    if (allowed != null && !allowed.contains(value)) {
      throw FormatException('File cadangan tidak valid.');
    }
    return value;
  }

  String? _optionalString(
    Map<String, dynamic> item,
    String key, {
    Set<String>? allowed,
  }) {
    final value = item[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('File cadangan tidak valid.');
    if (allowed != null && !allowed.contains(value)) {
      throw FormatException('File cadangan tidak valid.');
    }
    return value;
  }

  bool? _optionalBool(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null) return null;
    if (value is! bool) throw FormatException('File cadangan tidak valid.');
    return value;
  }

  DateTime _requiredDate(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value is! String) throw FormatException('File cadangan tidak valid.');
    final date = DateTime.tryParse(value);
    if (date == null) throw FormatException('File cadangan tidak valid.');
    return date;
  }
}

class BackupImportPreview {
  const BackupImportPreview({
    required this.payload,
    required this.transactions,
    required this.wallets,
    required this.categories,
    required this.budgets,
  });

  final Map<String, dynamic> payload;
  final int transactions;
  final int wallets;
  final int categories;
  final int budgets;
}
