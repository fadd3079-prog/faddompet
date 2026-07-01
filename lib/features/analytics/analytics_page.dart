import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/empty_state.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.contentBottomInset,
        ),
        children: [
          Text('Analitik', style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ringkasan visual akan muncul setelah kamu mencatat transaksi.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const EmptyState(
            icon: Icons.insights_rounded,
            title: 'Belum ada analitik',
            message:
                'Tambahkan beberapa transaksi untuk melihat ringkasan pemasukan, pengeluaran, dan kategori.',
          ),
        ],
      ),
    );
  }
}
