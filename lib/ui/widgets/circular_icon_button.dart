// Circular translucent control used for exit / chevrons / music / restart.
import 'package:flutter/material.dart';

/// Kid-friendly circular icon button with translucent fill.
class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.diameter,
    this.tooltip,
    this.foregroundColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double diameter;
  final String? tooltip;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.black.withValues(alpha: enabled ? 0.35 : 0.15),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Icon(
              icon,
              size: diameter * 0.5,
              color: foregroundColor.withValues(alpha: enabled ? 1 : 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
