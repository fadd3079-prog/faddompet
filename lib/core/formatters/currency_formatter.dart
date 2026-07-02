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

    return _format.format(amount).replaceAll(',00', '');
  }
}
