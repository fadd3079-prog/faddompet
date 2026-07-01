import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:faddompet/app/app.dart';
import 'package:faddompet/app/theme/app_theme.dart';
import 'package:faddompet/features/dashboard/dashboard_page.dart';
import 'package:faddompet/shared/widgets/premium_bottom_nav.dart';

void main() {
  testWidgets('Faddompet app shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const FaddompetApp());
    await tester.pumpAndSettle();

    expect(find.byType(PremiumBottomNav), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('Dashboard hierarchy renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total Saldo'), findsOneWidget);
    expect(find.text('Ringkasan bulan ini'), findsOneWidget);
    expect(find.text('Riwayat terbaru'), findsOneWidget);
  });
}
