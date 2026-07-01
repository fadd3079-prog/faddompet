import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double screen = 20;
  static const double webMaxWidth = 540;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screen,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
}
