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
      barrierColor: AppColors.scrim,
      builder: (context) {
        return const _QuickAddSheet();
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

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.webMaxWidth),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screen,
            right: AppSpacing.screen,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Transaksi', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pilih jenis transaksi yang ingin dicatat.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              _QuickAddOption(
                icon: Icons.south_west_rounded,
                title: 'Pengeluaran',
                subtitle: 'Catat uang keluar',
                accentColor: AppColors.expenseRed,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickAddOption(
                icon: Icons.north_east_rounded,
                title: 'Pemasukan',
                subtitle: 'Catat uang masuk',
                accentColor: AppColors.incomeGreen,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickAddOption(
                icon: Icons.swap_horiz_rounded,
                title: 'Transfer antar dompet',
                subtitle: 'Pindahkan saldo dari satu dompet ke dompet lain',
                accentColor: AppColors.infoBlue,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddOption extends StatelessWidget {
  const _QuickAddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
            ),
            boxShadow: AppShadows.soft(brightness),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.iconTile,
                height: AppSpacing.iconTile,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.11),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
