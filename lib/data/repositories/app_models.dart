import '../../core/enums/budget_status.dart';
import '../../core/enums/transaction_type.dart';
import '../local/database/app_database.dart';

class TransactionDetail {
  const TransactionDetail({
    required this.transaction,
    required this.wallet,
    this.category,
    this.transferWallet,
  });

  final TransactionEntry transaction;
  final WalletEntry wallet;
  final CategoryEntry? category;
  final WalletEntry? transferWallet;

  TransactionType get type => TransactionType.fromValue(transaction.type);
}

class WalletBalance {
  const WalletBalance({required this.wallet, required this.balance});

  final WalletEntry wallet;
  final int balance;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.netCashflow,
    required this.walletCount,
    required this.budgetLimit,
    required this.budgetSpent,
    required this.recentTransactions,
    required this.topExpenseCategory,
  });

  final int totalBalance;
  final int monthlyIncome;
  final int monthlyExpense;
  final int netCashflow;
  final int walletCount;
  final int budgetLimit;
  final int budgetSpent;
  final List<TransactionDetail> recentTransactions;
  final String? topExpenseCategory;

  double get budgetRatio {
    if (budgetLimit <= 0) {
      return 0;
    }
    return (budgetSpent / budgetLimit).clamp(0, 1);
  }
}

class CategoryAmount {
  const CategoryAmount({
    required this.label,
    required this.amount,
    required this.colorValue,
  });

  final String label;
  final int amount;
  final int colorValue;
}

class DailyCashflow {
  const DailyCashflow({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final int income;
  final int expense;
}

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.label,
    required this.spent,
    required this.status,
  });

  final BudgetEntry budget;
  final String label;
  final int spent;
  final BudgetStatus status;

  double get ratio {
    if (budget.limitAmount <= 0) {
      return 0;
    }
    return (spent / budget.limitAmount).clamp(0, 1);
  }
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.dailyCashflow,
    required this.weeklyExpense,
    required this.topExpenses,
  });

  final List<CategoryAmount> expenseByCategory;
  final List<CategoryAmount> incomeByCategory;
  final List<DailyCashflow> dailyCashflow;
  final List<CategoryAmount> weeklyExpense;
  final List<CategoryAmount> topExpenses;

  bool get isEmpty =>
      expenseByCategory.isEmpty &&
      incomeByCategory.isEmpty &&
      dailyCashflow.every((item) => item.income == 0 && item.expense == 0);
}
