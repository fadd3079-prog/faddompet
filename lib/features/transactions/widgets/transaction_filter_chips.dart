import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_durations.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class TransactionFilterChips extends StatelessWidget {
  const TransactionFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            _FilterChipButton(
              label: labels[index],
              selected: selectedIndex == index,
              accentColor: _accentForLabel(labels[index]),
              onTap: () => onChanged(index),
            ),
            if (index != labels.length - 1)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppDurations.easeOut,
          constraints: const BoxConstraints(minHeight: AppSpacing.iconTile),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: isDark ? 0.18 : 0.10)
                : (isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: isDark ? 0.38 : 0.22)
                  : (isDark
                        ? AppColors.darkBorderSubtle
                        : AppColors.borderSubtle),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected
                  ? accentColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

Color _accentForLabel(String label) {
  switch (label) {
    case 'Pemasukan':
      return AppColors.incomeGreen;
    case 'Pengeluaran':
      return AppColors.expenseRed;
    case 'Transfer':
      return AppColors.infoBlue;
    default:
      return AppColors.primary;
  }
}
