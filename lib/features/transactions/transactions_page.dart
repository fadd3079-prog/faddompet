import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/empty_state.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.contentBottomInset),
        child: EmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'Belum ada transaksi',
          message:
              'Tambahkan transaksi pertama untuk mulai membuat riwayat pemasukan dan pengeluaran.',
        ),
      ),
    );
  }
}
