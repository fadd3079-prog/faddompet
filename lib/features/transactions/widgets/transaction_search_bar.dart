import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class TransactionSearchBar extends StatelessWidget {
  const TransactionSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.huge + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari transaksi',
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: AppSpacing.xl,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
