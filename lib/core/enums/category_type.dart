enum CategoryType {
  income('income', 'Pemasukan'),
  expense('expense', 'Pengeluaran'),
  both('both', 'Semua');

  const CategoryType(this.value, this.label);

  final String value;
  final String label;
}
