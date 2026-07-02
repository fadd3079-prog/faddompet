import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../widgets/pressable_surface.dart';

class WalletChoiceChip extends StatelessWidget {
  const WalletChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onSelected;

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
                ? activeColor.withValues(alpha: isDark ? 0.16 : 0.10)
                : (isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected
                  ? activeColor.withValues(alpha: isDark ? 0.34 : 0.22)
                  : (isDark
                        ? AppColors.darkBorderSubtle
                        : AppColors.borderSubtle),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppSpacing.lg,
                  color: selected ? activeColor : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? activeColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
