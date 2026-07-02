import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import 'pressable_surface.dart';

class AppIconActionButton extends StatelessWidget {
  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final enabled = onPressed != null;
    final color = accentColor ?? theme.colorScheme.primary;
    final foreground = isDark ? AppColors.darkBackground : AppColors.onDark;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Tooltip(
        message: label,
        child: PressableSurface(
          enabled: enabled,
          onTap: onPressed,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: enabled ? 1 : 0.46,
            child: Container(
              width: AppSpacing.iconTile,
              height: AppSpacing.iconTile,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.36 : 0.18),
                ),
              ),
              child: Icon(
                icon,
                color: foreground,
                size: AppSpacing.navIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
