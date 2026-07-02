import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

enum TopToastType { success, error, warning, info }

class TopToast {
  TopToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    TopToastType type = TopToastType.info,
  }) {
    _timer?.cancel();
    _entry?.remove();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (context) => _TopToastContent(message: message, type: type),
    );
    overlay.insert(_entry!);
    _timer = Timer(const Duration(milliseconds: 2300), dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _TopToastContent extends StatelessWidget {
  const _TopToastContent({required this.message, required this.type});

  final String message;
  final TopToastType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final isDark = brightness == Brightness.dark;
    final color = _color(type);

    return Positioned(
      top: MediaQuery.paddingOf(context).top + AppSpacing.md,
      left: AppSpacing.screen,
      right: AppSpacing.screen,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, -10 + (10 * value)),
                child: child,
              ),
            );
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.webMaxWidth,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: color.withValues(alpha: 0.24)),
                    boxShadow: AppShadows.nav(brightness),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppSpacing.sm,
                        height: AppSpacing.sm,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Flexible(
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _color(TopToastType type) {
    switch (type) {
      case TopToastType.success:
        return AppColors.incomeGreen;
      case TopToastType.error:
        return AppColors.expenseRed;
      case TopToastType.warning:
        return AppColors.warningOrange;
      case TopToastType.info:
        return AppColors.infoBlue;
    }
  }
}
