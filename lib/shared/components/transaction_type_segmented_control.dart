import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class TransactionTypeSegmentedControl extends StatelessWidget {
  const TransactionTypeSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.accentColor,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: _SegmentedOption(
                label: labels[index],
                selected: index == selectedIndex,
                accentColor: accentColor,
                onTap: () => onChanged(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentedOption extends StatelessWidget {
  const _SegmentedOption({
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
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.darkSurfaceElevated : AppColors.surface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: selected
                ? Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.28 : 0.18),
                  )
                : null,
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
