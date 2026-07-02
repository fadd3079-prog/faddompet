import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.22)
        : const Color(0xFF0F172A).withValues(alpha: 0.045);

    return [
      BoxShadow(color: color, blurRadius: 18, offset: const Offset(0, 10)),
    ];
  }

  static List<BoxShadow> subtle(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.16)
        : const Color(0xFF0F172A).withValues(alpha: 0.025);

    return [
      BoxShadow(color: color, blurRadius: 10, offset: const Offset(0, 5)),
    ];
  }

  static List<BoxShadow> hero(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.30)
        : AppColors.primary.withValues(alpha: 0.16);

    return [
      BoxShadow(color: color, blurRadius: 28, offset: const Offset(0, 16)),
    ];
  }

  static List<BoxShadow> nav(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.34)
        : const Color(0xFF0F172A).withValues(alpha: 0.075);

    return [
      BoxShadow(color: color, blurRadius: 20, offset: const Offset(0, 10)),
    ];
  }

  static List<BoxShadow> frame(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.34)
        : const Color(0xFF0F172A).withValues(alpha: 0.10);

    return [
      BoxShadow(color: color, blurRadius: 30, offset: const Offset(0, 16)),
    ];
  }
}
