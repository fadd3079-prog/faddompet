import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_durations.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/pressable_surface.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
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
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useScrollableLayout =
            constraints.maxWidth < AppSpacing.compactControlWidth;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
            ),
          ),
          child: useScrollableLayout
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.hardEdge,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < labels.length; index++) ...[
                        _PeriodButton(
                          label: labels[index],
                          selected: selectedIndex == index,
                          onTap: () => onChanged(index),
                          compact: false,
                        ),
                        if (index != labels.length - 1)
                          const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  ),
                )
              : Row(
                  children: [
                    for (var index = 0; index < labels.length; index++)
                      Expanded(
                        child: _PeriodButton(
                          label: labels[index],
                          selected: selectedIndex == index,
                          onTap: () => onChanged(index),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.softMint : AppColors.primary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: PressableSurface(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppDurations.easeOut,
          constraints: const BoxConstraints(minHeight: AppSpacing.iconTile),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.darkSurfaceElevated : AppColors.surface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: selected
                ? Border.all(
                    color: activeColor.withValues(alpha: isDark ? 0.28 : 0.18),
                  )
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected
                  ? activeColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
