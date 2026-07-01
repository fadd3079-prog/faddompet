import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';

enum TransactionPreviewType { income, expense, transfer }

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.amount,
    required this.type,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String amount;
  final TransactionPreviewType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;
    final accentColor = _accentColor(type);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
        boxShadow: AppShadows.subtle(brightness),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconTile,
            height: AppSpacing.iconTile,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: accentColor, size: AppSpacing.xl),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(timeLabel, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _signedAmount(type, amount),
                maxLines: 1,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _typeLabel(type),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accentColor.withValues(alpha: isDark ? 0.88 : 0.82),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _accentColor(TransactionPreviewType type) {
  switch (type) {
    case TransactionPreviewType.income:
      return AppColors.incomeGreen;
    case TransactionPreviewType.expense:
      return AppColors.expenseRed;
    case TransactionPreviewType.transfer:
      return AppColors.infoBlue;
  }
}

String _signedAmount(TransactionPreviewType type, String amount) {
  switch (type) {
    case TransactionPreviewType.income:
      return '+$amount';
    case TransactionPreviewType.expense:
      return '-$amount';
    case TransactionPreviewType.transfer:
      return amount;
  }
}

String _typeLabel(TransactionPreviewType type) {
  switch (type) {
    case TransactionPreviewType.income:
      return 'Masuk';
    case TransactionPreviewType.expense:
      return 'Keluar';
    case TransactionPreviewType.transfer:
      return 'Transfer';
  }
}
