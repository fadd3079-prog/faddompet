enum WalletType {
  cash('cash', 'Tunai'),
  ewallet('ewallet', 'E-Wallet'),
  bank('bank', 'Rekening'),
  savings('savings', 'Tabungan');

  const WalletType(this.value, this.label);

  final String value;
  final String label;

  static WalletType fromValue(String value) {
    return WalletType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WalletType.cash,
    );
  }
}
