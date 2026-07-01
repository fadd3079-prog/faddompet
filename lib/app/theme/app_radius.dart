import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double hero = 32;
  static const double frame = 36;
  static const double full = 999;

  static BorderRadius get button => BorderRadius.circular(lg);
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xxl));
}
