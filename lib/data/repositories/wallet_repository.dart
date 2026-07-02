import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/helpers/calculation_helper.dart';
import '../local/database/app_database.dart';
import 'app_models.dart';

class WalletRepository {
  const WalletRepository(this._database);

  final AppDatabase _database;

  Stream<List<WalletBalance>> watchWalletBalances() {
    final controller = StreamController<List<WalletBalance>>();
    List<WalletEntry>? wallets;
    List<TransactionEntry>? transactions;

    void emit() {
      final currentWallets = wallets;
      final currentTransactions = transactions;
      if (currentWallets == null || currentTransactions == null) return;

      controller.add([
        for (final wallet in currentWallets)
          WalletBalance(
            wallet: wallet,
            balance: CalculationHelper.walletBalance(
              walletId: wallet.id,
              initialBalance: wallet.initialBalance,
              transactions: currentTransactions.map(
                (transaction) => (
                  walletId: transaction.walletId,
                  transferWalletId: transaction.transferWalletId,
                  type: transaction.type,
                  amount: transaction.amount,
                ),
              ),
            ),
          ),
      ]);
    }

    final walletSub = _database.walletsDao.watchAll().listen((value) {
      wallets = value;
      emit();
    });
    final transactionSub = _database.transactionsDao.watchAll().listen((value) {
      transactions = value;
      emit();
    });

    controller.onCancel = () async {
      await walletSub.cancel();
      await transactionSub.cancel();
    };

    return controller.stream;
  }

  Future<List<WalletEntry>> getWallets() {
    return _database.walletsDao.getAll();
  }

  Future<void> addWallet({
    required String name,
    required String type,
    int initialBalance = 0,
  }) async {
    final now = DateTime.now();
    await _database.walletsDao.add(
      WalletEntriesCompanion.insert(
        name: name.trim(),
        type: type,
        initialBalance: Value(initialBalance),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateWallet({
    required WalletEntry wallet,
    required String name,
    required String type,
    required int initialBalance,
  }) async {
    await _database.walletsDao.updateEntry(
      wallet
          .copyWith(
            name: name.trim(),
            type: type,
            initialBalance: initialBalance,
            updatedAt: DateTime.now(),
          )
          .toCompanion(true),
    );
  }

  Future<String?> deleteWallet(int walletId) async {
    final count = await _database.transactionsDao.countByWallet(walletId);
    if (count > 0) {
      return 'Dompet ini sudah dipakai di transaksi.';
    }

    await _database.walletsDao.deleteById(walletId);
    return null;
  }
}
