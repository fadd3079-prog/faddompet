import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:faddompet/app/app.dart';
import 'package:faddompet/app/providers/app_providers.dart';
import 'package:faddompet/app/theme/app_theme.dart';
import 'package:faddompet/data/local/database/app_database.dart';
import 'package:faddompet/data/repositories/app_models.dart';
import 'package:faddompet/features/dashboard/dashboard_page.dart';
import 'package:faddompet/shared/widgets/premium_bottom_nav.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('Faddompet app shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      _withOverrides(const FaddompetApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PremiumBottomNav), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('Dashboard hierarchy renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      _withOverrides(
        MaterialApp(theme: AppTheme.light, home: const DashboardPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Total Saldo'), findsOneWidget);
    expect(find.text('Ringkasan bulan ini'), findsOneWidget);
    expect(find.text('Riwayat terbaru'), findsOneWidget);
  });
}

Widget _withOverrides(Widget child) {
  final now = DateTime(2026, 7, 2, 9);
  final settings = AppSettingEntry(
    id: 1,
    userName: null,
    currency: 'IDR',
    themeMode: 'system',
    hideBalance: false,
    onboardingCompleted: true,
    createdAt: now,
    updatedAt: now,
  );
  final summary = DashboardSummary(
    totalBalance: 0,
    monthlyIncome: 0,
    monthlyExpense: 0,
    netCashflow: 0,
    walletCount: 4,
    budgetLimit: 0,
    budgetSpent: 0,
    recentTransactions: const [],
    topExpenseCategory: null,
  );
  final analytics = AnalyticsSummary(
    expenseByCategory: const [],
    incomeByCategory: const [],
    dailyCashflow: [
      for (var index = 0; index < 7; index++)
        DailyCashflow(date: now, income: 0, expense: 0),
    ],
    weeklyExpense: const [],
    topExpenses: const [],
  );

  return ProviderScope(
    overrides: [
      appBootstrapProvider.overrideWith((ref) async {}),
      appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
      dashboardSummaryProvider.overrideWith((ref) => Stream.value(summary)),
      transactionDetailsProvider.overrideWith((ref) => const Stream.empty()),
      walletBalancesProvider.overrideWith((ref) => const Stream.empty()),
      analyticsSummaryProvider.overrideWith((ref) => Stream.value(analytics)),
      budgetProgressProvider.overrideWith((ref) => const Stream.empty()),
      categoriesProvider.overrideWith((ref) => const Stream.empty()),
    ],
    child: child,
  );
}
