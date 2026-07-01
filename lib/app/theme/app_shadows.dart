import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.30)
        : const Color(0xFF0F172A).withValues(alpha: 0.07);

    return [
      BoxShadow(color: color, blurRadius: 26, offset: const Offset(0, 14)),
    ];
  }

  static List<BoxShadow> hero(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.36)
        : AppColors.primary.withValues(alpha: 0.20);

    return [
      BoxShadow(color: color, blurRadius: 34, offset: const Offset(0, 20)),
    ];
  }

  static List<BoxShadow> nav(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.48)
        : const Color(0xFF0F172A).withValues(alpha: 0.12);

    return [
      BoxShadow(color: color, blurRadius: 30, offset: const Offset(0, 16)),
    ];
  }
}
