import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class AppFormActions extends StatelessWidget {
  const AppFormActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    this.danger = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String secondaryLabel;
  final VoidCallback onSecondaryPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final primaryStyle = danger
        ? FilledButton.styleFrom(
            backgroundColor: AppColors.expenseRed,
            foregroundColor: AppColors.onDark,
          )
        : null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSecondaryPressed,
            child: Text(
              secondaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton(
            style: primaryStyle,
            onPressed: onPrimaryPressed,
            child: Text(
              primaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
