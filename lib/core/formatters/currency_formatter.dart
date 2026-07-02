import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String rupiah(int amount, {bool hidden = false}) {
    if (hidden) {
      return 'Rp••••';
    }

    return _format.format(amount).replaceAll(RegExp(r'\s+'), '');
  }

  static int parseRupiah(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}
