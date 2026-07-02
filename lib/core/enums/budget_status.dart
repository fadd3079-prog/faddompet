enum BudgetStatus {
  safe('Aman'),
  nearLimit('Mendekati batas'),
  exceeded('Terlampaui');

  const BudgetStatus(this.label);

  final String label;
}
