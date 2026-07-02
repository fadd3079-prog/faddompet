import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';

class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 72, this.radius = AppRadius.xl});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'FadDompet',
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
