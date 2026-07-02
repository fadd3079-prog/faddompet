import '../enums/budget_status.dart';
import '../enums/transaction_type.dart';

class CalculationHelper {
  CalculationHelper._();

  static int walletBalance({
    required int walletId,
    required int initialBalance,
    required Iterable<
      ({int walletId, int? transferWalletId, String type, int amount})
    >
    transactions,
  }) {
    var balance = initialBalance;

    for (final transaction in transactions) {
      final type = TransactionType.fromValue(transaction.type);
      switch (type) {
        case TransactionType.income:
          if (transaction.walletId == walletId) {
            balance += transaction.amount;
          }
        case TransactionType.expense:
          if (transaction.walletId == walletId) {
            balance -= transaction.amount;
          }
        case TransactionType.transfer:
          if (transaction.walletId == walletId) {
            balance -= transaction.amount;
          }
          if (transaction.transferWalletId == walletId) {
            balance += transaction.amount;
          }
      }
    }

    return balance;
  }

  static BudgetStatus budgetStatus(int spent, int limit) {
    if (limit <= 0) {
      return BudgetStatus.safe;
    }

    final ratio = spent / limit;
    if (ratio >= 1) {
      return BudgetStatus.exceeded;
    }
    if (ratio >= 0.8) {
      return BudgetStatus.nearLimit;
    }
    return BudgetStatus.safe;
  }
}
