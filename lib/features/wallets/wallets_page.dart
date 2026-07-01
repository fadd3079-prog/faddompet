import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallets = [
      ('Cash', 'Rp0', Icons.payments_rounded, AppColors.incomeGreen),
      ('DANA', 'Rp0', Icons.account_balance_wallet_rounded, AppColors.infoBlue),
      ('Rekening', 'Rp0', Icons.account_balance_rounded, AppColors.primary),
    ];
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          Text('Wallet', style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kelola saldo cash, e-wallet, rekening, dan tabungan.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          ...wallets.map(
            (wallet) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _WalletCard(
                name: wallet.$1,
                balance: wallet.$2,
                icon: wallet.$3,
                accentColor: wallet.$4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.name,
    required this.balance,
    required this.icon,
    required this.accentColor,
  });

  final String name;
  final String balance;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.11),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Saldo saat ini', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Text(
            balance,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
