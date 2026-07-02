import 'dart:async';

import '../../core/enums/transaction_type.dart';
import '../../core/formatters/date_formatter.dart';
import '../local/database/app_database.dart';
import 'app_models.dart';

class AnalyticsRepository {
  const AnalyticsRepository(this._database);

  final AppDatabase _database;

  Stream<AnalyticsSummary> watchSummary() {
    final controller = StreamController<AnalyticsSummary>();
    List<TransactionEntry>? transactions;
    List<CategoryEntry>? categories;

    void emit() {
      final currentTransactions = transactions;
      final currentCategories = categories;
      if (currentTransactions == null || currentCategories == null) return;
      controller.add(_summary(currentTransactions, currentCategories));
    }

    final transactionSub = _database.transactionsDao.watchAll().listen((value) {
      transactions = value;
      emit();
    });
    final categorySub = _database.categoriesDao.watchAll().listen((value) {
      categories = value;
      emit();
    });

    controller.onCancel = () async {
      await transactionSub.cancel();
      await categorySub.cancel();
    };

    return controller.stream;
  }

  AnalyticsSummary _summary(
    List<TransactionEntry> transactions,
    List<CategoryEntry> categories,
  ) {
    final now = DateTime.now();
    final start = DateFormatter.startOfMonth(now);
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final monthly = transactions
        .where((item) => !item.date.isBefore(start))
        .toList();

    return AnalyticsSummary(
      expenseByCategory: _categoryAmounts(
        monthly,
        categoriesById,
        TransactionType.expense,
      ),
      incomeByCategory: _categoryAmounts(
        monthly,
        categoriesById,
        TransactionType.income,
      ),
      dailyCashflow: _dailyCashflow(monthly),
      weeklyExpense: _weeklyExpense(monthly),
      topExpenses: _categoryAmounts(
        monthly,
        categoriesById,
        TransactionType.expense,
      ).take(5).toList(),
    );
  }

  List<CategoryAmount> _categoryAmounts(
    List<TransactionEntry> transactions,
    Map<int, CategoryEntry> categories,
    TransactionType type,
  ) {
    final totals = <int, int>{};
    for (final transaction in transactions) {
      if (TransactionType.fromValue(transaction.type) != type) continue;
      final categoryId = transaction.categoryId;
      if (categoryId == null) continue;
      totals[categoryId] = (totals[categoryId] ?? 0) + transaction.amount;
    }

    final items = [
      for (final entry in totals.entries)
        if (categories[entry.key] != null)
          CategoryAmount(
            label: categories[entry.key]!.name,
            amount: entry.value,
            colorValue: categories[entry.key]!.colorValue,
          ),
    ];

    items.sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  List<DailyCashflow> _dailyCashflow(List<TransactionEntry> transactions) {
    final now = DateTime.now();
    return [
      for (var index = 6; index >= 0; index--)
        _cashflowForDay(
          DateFormatter.startOfDay(now.subtract(Duration(days: index))),
          transactions,
        ),
    ];
  }

  DailyCashflow _cashflowForDay(
    DateTime date,
    List<TransactionEntry> transactions,
  ) {
    final next = date.add(const Duration(days: 1));
    var income = 0;
    var expense = 0;

    for (final transaction in transactions) {
      if (transaction.date.isBefore(date) || !transaction.date.isBefore(next)) {
        continue;
      }
      switch (TransactionType.fromValue(transaction.type)) {
        case TransactionType.income:
          income += transaction.amount;
        case TransactionType.expense:
          expense += transaction.amount;
        case TransactionType.transfer:
      }
    }

    return DailyCashflow(date: date, income: income, expense: expense);
  }

  List<CategoryAmount> _weeklyExpense(List<TransactionEntry> transactions) {
    final now = DateTime.now();
    return [
      for (var index = 3; index >= 0; index--)
        _expenseForWeek(
          DateFormatter.startOfWeek(now.subtract(Duration(days: index * 7))),
          transactions,
          'M${4 - index}',
        ),
    ];
  }

  CategoryAmount _expenseForWeek(
    DateTime start,
    List<TransactionEntry> transactions,
    String label,
  ) {
    final end = start.add(const Duration(days: 7));
    final amount = transactions
        .where(
          (transaction) =>
              !transaction.date.isBefore(start) &&
              transaction.date.isBefore(end) &&
              TransactionType.fromValue(transaction.type) ==
                  TransactionType.expense,
        )
        .fold<int>(0, (total, transaction) => total + transaction.amount);

    return CategoryAmount(label: label, amount: amount, colorValue: 0xFFDC2626);
  }
}
