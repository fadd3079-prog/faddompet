import 'dart:async';

import '../../core/enums/analytics_period.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/formatters/date_formatter.dart';
import '../local/database/app_database.dart';
import 'app_models.dart';

class AnalyticsRepository {
  const AnalyticsRepository(this._database);

  final AppDatabase _database;

  Stream<AnalyticsSummary> watchSummary(AnalyticsPeriod period) {
    final controller = StreamController<AnalyticsSummary>();
    List<TransactionEntry>? transactions;
    List<CategoryEntry>? categories;

    void emit() {
      final currentTransactions = transactions;
      final currentCategories = categories;
      if (currentTransactions == null || currentCategories == null) return;
      controller.add(_summary(currentTransactions, currentCategories, period));
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
    AnalyticsPeriod period,
  ) {
    final now = DateTime.now();
    final start = period.startDate(now);
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final filtered = transactions
        .where((item) => start == null || !item.date.isBefore(start))
        .toList();

    return AnalyticsSummary(
      expenseByCategory: _categoryAmounts(
        filtered,
        categoriesById,
        TransactionType.expense,
      ),
      incomeByCategory: _categoryAmounts(
        filtered,
        categoriesById,
        TransactionType.income,
      ),
      dailyCashflow: _cashflowSeries(filtered, period, now),
      weeklyExpense: _expenseBuckets(filtered, period, now),
      topExpenses: _categoryAmounts(
        filtered,
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

  List<DailyCashflow> _cashflowSeries(
    List<TransactionEntry> transactions,
    AnalyticsPeriod period,
    DateTime now,
  ) {
    switch (period) {
      case AnalyticsPeriod.currentMonth:
        final start = DateFormatter.startOfMonth(now);
        final today = DateFormatter.startOfDay(now);
        final days = today.difference(start).inDays + 1;
        return [
          for (var index = 0; index < days; index++)
            _cashflowForRange(
              start.add(Duration(days: index)),
              start.add(Duration(days: index + 1)),
              transactions,
            ),
        ];
      case AnalyticsPeriod.last3Months:
        return _monthlyCashflow(
          transactions,
          DateTime(now.year, now.month - 2),
          now,
        );
      case AnalyticsPeriod.yearToDate:
        return _monthlyCashflow(transactions, DateTime(now.year), now);
      case AnalyticsPeriod.allTime:
        if (transactions.isEmpty) return const [];
        return _monthlyCashflow(
          transactions,
          _allTimeChartStart(transactions, now),
          now,
        );
    }
  }

  List<DailyCashflow> _monthlyCashflow(
    List<TransactionEntry> transactions,
    DateTime start,
    DateTime now,
  ) {
    return [
      for (final monthStart in _monthStarts(start, now))
        _cashflowForRange(monthStart, _nextMonth(monthStart), transactions),
    ];
  }

  DailyCashflow _cashflowForRange(
    DateTime start,
    DateTime end,
    List<TransactionEntry> transactions,
  ) {
    var income = 0;
    var expense = 0;

    for (final transaction in transactions) {
      if (transaction.date.isBefore(start) || !transaction.date.isBefore(end)) {
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

    return DailyCashflow(date: start, income: income, expense: expense);
  }

  List<CategoryAmount> _expenseBuckets(
    List<TransactionEntry> transactions,
    AnalyticsPeriod period,
    DateTime now,
  ) {
    switch (period) {
      case AnalyticsPeriod.currentMonth:
        return _weeklyExpense(transactions, now);
      case AnalyticsPeriod.last3Months:
        return _monthlyExpense(
          transactions,
          DateTime(now.year, now.month - 2),
          now,
        );
      case AnalyticsPeriod.yearToDate:
        return _monthlyExpense(transactions, DateTime(now.year), now);
      case AnalyticsPeriod.allTime:
        if (transactions.isEmpty) return const [];
        return _monthlyExpense(
          transactions,
          _allTimeChartStart(transactions, now),
          now,
        );
    }
  }

  List<CategoryAmount> _weeklyExpense(
    List<TransactionEntry> transactions,
    DateTime now,
  ) {
    final start = DateFormatter.startOfMonth(now);
    final buckets = <CategoryAmount>[];
    var bucketStart = start;
    var index = 1;

    while (!bucketStart.isAfter(now)) {
      final bucketEnd = bucketStart.add(const Duration(days: 7));
      buckets.add(
        _expenseForRange(bucketStart, bucketEnd, transactions, 'Minggu $index'),
      );
      bucketStart = bucketEnd;
      index += 1;
    }

    return buckets;
  }

  List<CategoryAmount> _monthlyExpense(
    List<TransactionEntry> transactions,
    DateTime start,
    DateTime now,
  ) {
    return [
      for (final monthStart in _monthStarts(start, now))
        _expenseForRange(
          monthStart,
          _nextMonth(monthStart),
          transactions,
          _shortMonthLabel(monthStart),
        ),
    ];
  }

  CategoryAmount _expenseForRange(
    DateTime start,
    DateTime end,
    List<TransactionEntry> transactions,
    String label,
  ) {
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

  List<DateTime> _monthStarts(DateTime start, DateTime now) {
    final end = DateFormatter.startOfMonth(now);
    final starts = <DateTime>[];
    var cursor = DateFormatter.startOfMonth(start);

    while (!cursor.isAfter(end)) {
      starts.add(cursor);
      cursor = _nextMonth(cursor);
    }

    return starts;
  }

  DateTime _nextMonth(DateTime value) {
    return DateTime(value.year, value.month + 1);
  }

  DateTime _allTimeChartStart(
    List<TransactionEntry> transactions,
    DateTime now,
  ) {
    final earliest = transactions
        .map((transaction) => DateFormatter.startOfMonth(transaction.date))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final latestWindowStart = DateTime(now.year, now.month - 11);
    return earliest.isAfter(latestWindowStart) ? earliest : latestWindowStart;
  }

  String _shortMonthLabel(DateTime date) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return labels[date.month - 1];
  }
}
