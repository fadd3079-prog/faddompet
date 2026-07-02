import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class CategoryGroupSection extends StatelessWidget {
  const CategoryGroupSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
