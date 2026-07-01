import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallets = [
      ('Cash', 'Rp0', Icons.payments_rounded, AppColors.green),
      ('DANA', 'Rp0', Icons.account_balance_wallet_rounded, AppColors.blue),
      ('Rekening', 'Rp0', Icons.account_balance_rounded, AppColors.primary),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Wallet',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kelola saldo cash, e-wallet, rekening, dan tabungan.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ...wallets.map(
            (wallet) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: wallet.$4.withValues(alpha: 0.12),
                      foregroundColor: wallet.$4,
                      child: Icon(wallet.$3),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        wallet.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      wallet.$2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
