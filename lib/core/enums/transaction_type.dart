enum TransactionType {
  expense('expense', 'Pengeluaran'),
  income('income', 'Pemasukan'),
  transfer('transfer', 'Transfer');

  const TransactionType(this.value, this.label);

  final String value;
  final String label;

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.expense,
    );
  }
}
