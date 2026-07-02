import 'package:flutter/material.dart';

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

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.huge + AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Cari transaksi',
          hintText: 'Nama, catatan, atau dompet',
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
