import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.borderSubtle,
              ),
            ),
            child: Text(message, style: theme.textTheme.labelLarge),
          ),
        ),
      ),
    );
  }
}
