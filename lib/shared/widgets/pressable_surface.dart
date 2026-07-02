import 'package:flutter/material.dart';

import '../../app/theme/app_durations.dart';

class PressableSurface extends StatefulWidget {
  const PressableSurface({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.98,
    this.opacity = 0.92,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final double opacity;
  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<PressableSurface> createState() => _PressableSurfaceState();
}

class _PressableSurfaceState extends State<PressableSurface> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (!_interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      behavior: widget.behavior,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppDurations.fast,
        curve: AppDurations.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? widget.opacity : 1,
          duration: AppDurations.fast,
          curve: AppDurations.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
