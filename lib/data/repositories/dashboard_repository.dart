import 'dart:async';

import '../../core/enums/transaction_type.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/helpers/calculation_helper.dart';
import '../local/database/app_database.dart';
import 'app_models.dart';

class DashboardRepository {
  const DashboardRepository(this._database);

  final AppDatabase _database;

  Stream<DashboardSummary> watchSummary() {
    final controller = StreamController<DashboardSummary>();
    List<TransactionEntry>? transactions;
    List<CategoryEntry>? categories;
    List<WalletEntry>? wallets;
    List<BudgetEntry>? budgets;

    void emit() {
      final currentTransactions = transactions;
      final currentCategories = categories;
      final currentWallets = wallets;
      final currentBudgets = budgets;
      if (currentTransactions == null ||
          currentCategories == null ||
          currentWallets == null ||
          currentBudgets == null) {
        return;
      }

      controller.add(
        _summary(
          transactions: currentTransactions,
          categories: currentCategories,
          wallets: currentWallets,
          budgets: currentBudgets,
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
    final budgetSub = _database.budgetsDao.watchAll().listen((value) {
      budgets = value;
      emit();
    });

    controller.onCancel = () async {
      await transactionSub.cancel();
      await categorySub.cancel();
      await walletSub.cancel();
      await budgetSub.cancel();
    };

    return controller.stream;
  }

  DashboardSummary _summary({
    required List<TransactionEntry> transactions,
    required List<CategoryEntry> categories,
    required List<WalletEntry> wallets,
    required List<BudgetEntry> budgets,
  }) {
    final now = DateTime.now();
    final start = DateFormatter.startOfMonth(now);
    final monthKey = DateFormatter.monthKey(now);
    final monthly = transactions.where((item) => !item.date.isBefore(start));
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final walletsById = {for (final wallet in wallets) wallet.id: wallet};

    final walletBalances = [
      for (final wallet in wallets)
        CalculationHelper.walletBalance(
          walletId: wallet.id,
          initialBalance: wallet.initialBalance,
          transactions: transactions.map(
            (transaction) => (
              walletId: transaction.walletId,
              transferWalletId: transaction.transferWalletId,
              type: transaction.type,
              amount: transaction.amount,
            ),
          ),
        ),
    ];

    final monthlyIncome = monthly
        .where(
          (item) =>
              TransactionType.fromValue(item.type) == TransactionType.income,
        )
        .fold<int>(0, (total, item) => total + item.amount);
    final monthlyExpense = monthly
        .where(
          (item) =>
              TransactionType.fromValue(item.type) == TransactionType.expense,
        )
        .fold<int>(0, (total, item) => total + item.amount);

    final currentBudgets = budgets
        .where((budget) => budget.month == monthKey)
        .toList();
    final monthlyBudgetLimit = currentBudgets
        .where((budget) => budget.categoryId == null)
        .fold<int>(0, (total, budget) => total + budget.limitAmount);
    final categoryBudgetLimitTotal = currentBudgets
        .where((budget) => budget.categoryId != null)
        .fold<int>(0, (total, budget) => total + budget.limitAmount);
    final budgetLimit = monthlyBudgetLimit > 0
        ? monthlyBudgetLimit
        : categoryBudgetLimitTotal;

    final categoryTotals = <int, int>{};
    for (final transaction in monthly) {
      if (TransactionType.fromValue(transaction.type) !=
          TransactionType.expense) {
        continue;
      }
      final categoryId = transaction.categoryId;
      if (categoryId == null) continue;
      categoryTotals[categoryId] =
          (categoryTotals[categoryId] ?? 0) + transaction.amount;
    }

    final topCategoryId = categoryTotals.entries.isEmpty
        ? null
        : categoryTotals.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;

    return DashboardSummary(
      totalBalance: walletBalances.fold<int>(0, (total, item) => total + item),
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      netCashflow: monthlyIncome - monthlyExpense,
      walletCount: wallets.length,
      budgetLimit: budgetLimit,
      budgetSpent: monthlyExpense,
      budgetCount: currentBudgets.length,
      hasMonthlyBudget: monthlyBudgetLimit > 0,
      categoryBudgetLimitTotal: categoryBudgetLimitTotal,
      topExpenseCategory: categoriesById[topCategoryId]?.name,
      recentTransactions: [
        for (final transaction in transactions.take(5))
          if (walletsById[transaction.walletId] != null)
            TransactionDetail(
              transaction: transaction,
              category: categoriesById[transaction.categoryId],
              wallet: walletsById[transaction.walletId]!,
              transferWallet: walletsById[transaction.transferWalletId],
            ),
      ],
    );
  }
}
