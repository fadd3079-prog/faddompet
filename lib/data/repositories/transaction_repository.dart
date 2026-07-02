import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/enums/transaction_type.dart';
import '../local/database/app_database.dart';
import 'app_models.dart';

class TransactionRepository {
  const TransactionRepository(this._database);

  final AppDatabase _database;

  Stream<List<TransactionDetail>> watchDetails() {
    final controller = StreamController<List<TransactionDetail>>();
    List<TransactionEntry>? transactions;
    List<CategoryEntry>? categories;
    List<WalletEntry>? wallets;

    void emit() {
      final currentTransactions = transactions;
      final currentCategories = categories;
      final currentWallets = wallets;
      if (currentTransactions == null ||
          currentCategories == null ||
          currentWallets == null) {
        return;
      }

      controller.add(
        _details(
          transactions: currentTransactions,
          categories: currentCategories,
          wallets: currentWallets,
        ),
      );
    }

    final transactionSub = _database.transactionsDao.watchAll().listen((value) {
      transactions = value;
      emit();
    });
    final categorySub = _database.categoriesDao.watchAll().listen((value) {
      categories = value;
      emit();
    });
    final walletSub = _database.walletsDao.watchAll().listen((value) {
      wallets = value;
      emit();
    });

    controller.onCancel = () async {
      await transactionSub.cancel();
      await categorySub.cancel();
      await walletSub.cancel();
    };

    return controller.stream;
  }

  Future<List<TransactionDetail>> getDetails() async {
    final transactions = await _database.transactionsDao.getAll();
    final categories = await _database.categoriesDao.getAll();
    final wallets = await _database.walletsDao.getAll();
    return _details(
      transactions: transactions,
      categories: categories,
      wallets: wallets,
    );
  }

  Future<void> save({
    int? id,
    required TransactionType type,
    required int amount,
    int? categoryId,
    required int walletId,
    int? transferWalletId,
    required DateTime date,
    String? note,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Masukkan nominal terlebih dahulu.');
    }
    if (type != TransactionType.transfer && categoryId == null) {
      throw ArgumentError('Pilih kategori terlebih dahulu.');
    }
    if (type == TransactionType.transfer) {
      if (transferWalletId == null) {
        throw ArgumentError('Pilih dompet tujuan terlebih dahulu.');
      }
      if (transferWalletId == walletId) {
        throw ArgumentError('Pilih dompet tujuan yang berbeda.');
      }
    }

    final now = DateTime.now();
    final existing = id == null
        ? null
        : await _database.transactionsDao.getById(id);
    final companion = TransactionEntriesCompanion(
      id: id == null ? const Value.absent() : Value(id),
      type: Value(type.value),
      amount: Value(amount),
      categoryId: Value(type == TransactionType.transfer ? null : categoryId),
      walletId: Value(walletId),
      transferWalletId: Value(
        type == TransactionType.transfer ? transferWalletId : null,
      ),
      date: Value(date),
      note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    if (id == null) {
      await _database.transactionsDao.add(companion);
    } else {
      await _database.transactionsDao.updateEntry(companion);
    }
  }

  Future<void> delete(int id) async {
    await _database.transactionsDao.deleteById(id);
  }

  List<TransactionDetail> _details({
    required List<TransactionEntry> transactions,
    required List<CategoryEntry> categories,
    required List<WalletEntry> wallets,
  }) {
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final walletsById = {for (final wallet in wallets) wallet.id: wallet};

    return [
      for (final transaction in transactions)
        if (walletsById[transaction.walletId] != null)
          TransactionDetail(
            transaction: transaction,
            category: categoriesById[transaction.categoryId],
            wallet: walletsById[transaction.walletId]!,
            transferWallet: walletsById[transaction.transferWalletId],
          ),
    ];
  }
}
