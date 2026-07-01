import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/analytics/analytics_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/transactions/transactions_page.dart';
import '../../features/wallets/wallets_page.dart';
import '../components/add_transaction_sheet.dart';
import '../widgets/premium_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    TransactionsPage(),
    AnalyticsPage(),
    WalletsPage(),
    SettingsPage(),
  ];

  void _showQuickAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (context) {
        return const AddTransactionSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = const [
      PremiumBottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Beranda',
      ),
      PremiumBottomNavItem(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: 'Transaksi',
      ),
      PremiumBottomNavItem(
        icon: Icons.donut_large_outlined,
        selectedIcon: Icons.donut_large_rounded,
        label: 'Analitik',
      ),
      PremiumBottomNavItem(
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet_rounded,
        label: 'Dompet',
      ),
      PremiumBottomNavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: 'Pengaturan',
      ),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);
          final brightness = theme.colorScheme.brightness;
          final isDark = brightness == Brightness.dark;
          final showFrame =
              constraints.maxWidth > AppSpacing.webMaxWidth + AppSpacing.huge;
          final frameWidth = showFrame
              ? AppSpacing.webMaxWidth
              : constraints.maxWidth;
          final frameHeight = showFrame
              ? constraints.maxHeight - (AppSpacing.webFrameMargin * 2)
              : constraints.maxHeight;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackgroundSoft
                  : AppColors.backgroundSoft,
            ),
            child: Center(
              child: Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: showFrame
                      ? BorderRadius.circular(AppRadius.frame)
                      : BorderRadius.zero,
                  border: showFrame
                      ? Border.all(
                          color: isDark
                              ? AppColors.darkFrameBorder
                              : AppColors.frameBorder,
                        )
                      : null,
                  boxShadow: showFrame ? AppShadows.frame(brightness) : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _pages,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: PremiumBottomNav(
                        currentIndex: _currentIndex,
                        items: navItems,
                        onAddPressed: _showQuickAddSheet,
                        onChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
