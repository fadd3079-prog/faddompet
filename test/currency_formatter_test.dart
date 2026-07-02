import 'package:flutter_test/flutter_test.dart';

import 'package:faddompet/core/formatters/currency_formatter.dart';

void main() {
  test('formats Rupiah with Indonesian thousand separators', () {
    expect(CurrencyFormatter.rupiah(25000), 'Rp25.000');
    expect(CurrencyFormatter.rupiah(2500000), 'Rp2.500.000');
    expect(CurrencyFormatter.rupiah(100000), 'Rp100.000');
  });

  test('parses formatted Rupiah text back to integer', () {
    expect(CurrencyFormatter.parseRupiah('Rp2.500.000'), 2500000);
    expect(CurrencyFormatter.parseRupiah('25.000'), 25000);
    expect(CurrencyFormatter.parseRupiah(''), 0);
  });
}
