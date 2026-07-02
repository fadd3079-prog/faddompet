import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../widgets/pressable_surface.dart';

class DateChoiceChip extends StatelessWidget {
  const DateChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final activeColor = AppColors.infoBlue;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: PressableSurface(
        onTap: onSelected,
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
                ? activeColor.withValues(alpha: isDark ? 0.18 : 0.10)
                : (isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected
                  ? activeColor.withValues(alpha: isDark ? 0.36 : 0.22)
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
                  ? activeColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
