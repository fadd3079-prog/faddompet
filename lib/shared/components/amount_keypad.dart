import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.accentColor,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KeypadRow(
          keys: const ['1', '2', '3'],
          accentColor: accentColor,
          onDigitPressed: onDigitPressed,
          onBackspacePressed: onBackspacePressed,
        ),
        const SizedBox(height: AppSpacing.sm),
        _KeypadRow(
          keys: const ['4', '5', '6'],
          accentColor: accentColor,
          onDigitPressed: onDigitPressed,
          onBackspacePressed: onBackspacePressed,
        ),
        const SizedBox(height: AppSpacing.sm),
        _KeypadRow(
          keys: const ['7', '8', '9'],
          accentColor: accentColor,
          onDigitPressed: onDigitPressed,
          onBackspacePressed: onBackspacePressed,
        ),
        const SizedBox(height: AppSpacing.sm),
        _KeypadRow(
          keys: const ['000', '0', 'backspace'],
          accentColor: accentColor,
          onDigitPressed: onDigitPressed,
          onBackspacePressed: onBackspacePressed,
        ),
      ],
    );
  }
}

class _KeypadRow extends StatelessWidget {
  const _KeypadRow({
    required this.keys,
    required this.accentColor,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  final List<String> keys;
  final Color accentColor;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < keys.length; index++) ...[
          Expanded(
            child: _KeypadButton(
              value: keys[index],
              accentColor: accentColor,
              onPressed: keys[index] == 'backspace'
                  ? onBackspacePressed
                  : () => onDigitPressed(keys[index]),
            ),
          ),
          if (index != keys.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.value,
    required this.accentColor,
    required this.onPressed,
  });

  final String value;
  final Color accentColor;
  final VoidCallback onPressed;

  bool get _isBackspace => value == 'backspace';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: _isBackspace ? 'Hapus angka' : value,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.huge + AppSpacing.md,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.borderSubtle,
            ),
          ),
          child: _isBackspace
              ? Icon(Icons.backspace_outlined, color: accentColor, size: 21)
              : Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
        ),
      ),
    );
  }
}
