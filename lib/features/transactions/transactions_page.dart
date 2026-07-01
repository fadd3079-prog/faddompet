import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Belum ada transaksi',
        message:
            'Transaksi pemasukan, pengeluaran, dan transfer wallet akan muncul di sini.',
      ),
    );
  }
}
