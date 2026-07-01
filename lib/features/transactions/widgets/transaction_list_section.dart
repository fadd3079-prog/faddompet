import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'transaction_tile.dart';

class TransactionListSection extends StatelessWidget {
  const TransactionListSection({
    super.key,
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<TransactionTile> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < transactions.length; index++) ...[
          transactions[index],
          if (index != transactions.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
