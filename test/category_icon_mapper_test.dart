import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:faddompet/shared/helpers/category_icon_mapper.dart';

void main() {
  test('food category does not use generic fallback icon', () {
    expect(
      categoryIconFromKey('category', name: 'Makanan'),
      isNot(Icons.category_rounded),
    );
  });

  test('cashback and project have distinct icons', () {
    expect(
      categoryIconFromKey('cashback', name: 'Cashback'),
      isNot(categoryIconFromKey('project', name: 'Project')),
    );
  });

  test('freelance and gift have distinct icons', () {
    expect(
      categoryIconFromKey('freelance', name: 'Freelance'),
      isNot(categoryIconFromKey('gift', name: 'Hadiah')),
    );
  });

  test('other category falls back to generic category icon', () {
    expect(
      categoryIconFromKey('category', name: 'Lainnya'),
      Icons.category_rounded,
    );
  });
}
