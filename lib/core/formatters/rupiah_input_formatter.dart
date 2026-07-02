import 'package:flutter/services.dart';

import 'currency_formatter.dart';

class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final amount = CurrencyFormatter.parseRupiah(newValue.text);
    if (amount == 0) {
      return const TextEditingValue();
    }

    final text = CurrencyFormatter.rupiah(amount);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
