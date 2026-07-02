import 'package:flutter_test/flutter_test.dart';

import 'package:faddompet/core/enums/transaction_type.dart';
import 'package:faddompet/core/helpers/calculation_helper.dart';

void main() {
  test('transfer moves money between wallets without becoming expense', () {
    final transactions =
        <({int walletId, int? transferWalletId, String type, int amount})>[
          (
            walletId: 1,
            transferWalletId: 2,
            type: TransactionType.transfer.value,
            amount: 100000,
          ),
          (
            walletId: 2,
            transferWalletId: null,
            type: TransactionType.expense.value,
            amount: 25000,
          ),
          (
            walletId: 1,
            transferWalletId: null,
            type: TransactionType.income.value,
            amount: 50000,
          ),
        ];

    final sourceBalance = CalculationHelper.walletBalance(
      walletId: 1,
      initialBalance: 200000,
      transactions: transactions,
    );
    final destinationBalance = CalculationHelper.walletBalance(
      walletId: 2,
      initialBalance: 0,
      transactions: transactions,
    );

    expect(sourceBalance, 150000);
    expect(destinationBalance, 75000);
  });
}
