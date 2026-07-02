import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    super.key,
    required this.totalBalance,
    required this.walletInfo,
    required this.monthlyStatus,
    this.hideBalance = false,
    this.onToggleVisibility,
  });

  final String totalBalance;
  final String walletInfo;
  final String monthlyStatus;
  final bool hideBalance;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).colorScheme.brightness;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 218),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.hero),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.deepNavy,
          ],
        ),
        border: Border.all(color: AppColors.onDarkBorder),
        boxShadow: AppShadows.hero(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Saldo',
                  style: TextStyle(
                    color: AppColors.onDarkMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: AppSpacing.iconTileSmall,
                  height: AppSpacing.iconTileSmall,
                  decoration: BoxDecoration(
                    color: AppColors.onDarkSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.onDarkBorder),
                  ),
                  child: Icon(
                    hideBalance
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.onDark,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              totalBalance,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.onDark,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: 0,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Saldo dari semua dompet yang tercatat',
            style: TextStyle(
              color: AppColors.onDarkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: _HeroInfoTile(label: 'Dompet', value: walletInfo),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroInfoTile(
                  label: 'Status bulan ini',
                  value: monthlyStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroInfoTile extends StatelessWidget {
  const _HeroInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.onDarkSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.onDarkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.onDarkFaint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onDark,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
