// Safe-area overlay controls: exit / chevrons / music / restart.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'circular_icon_button.dart';

/// Which chrome buttons to show for the current page.
enum OverlayChromeMode {
  cover,
  spread,
  backCover,
}

/// Positions controls using DESIGN §3.2.2 safe-area formulas.
class OverlayControls extends StatelessWidget {
  const OverlayControls({
    super.key,
    required this.mode,
    required this.musicOn,
    required this.onExit,
    required this.onMusicToggle,
    this.onForward,
    this.onBack,
    this.onRestart,
    this.visible = true,
  });

  final OverlayChromeMode mode;
  final bool musicOn;
  final VoidCallback onExit;
  final VoidCallback onMusicToggle;
  final VoidCallback? onForward;
  final VoidCallback? onBack;
  final VoidCallback? onRestart;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    final padding = media.padding;
    final safeWidth = media.size.width - padding.left - padding.right;
    final safeHeight = media.size.height - padding.top - padding.bottom;
    final shortest = math.min(safeWidth, safeHeight);

    final buttonDiameter = math.max(48.0, 0.09 * shortest);
    final edgeGap = math.max(8.0, 0.02 * shortest);
    // Bottom band: one diameter + gap above safe bottom.
    final bottomBandTop =
        padding.top + safeHeight - (edgeGap + buttonDiameter);

    final musicIcon = musicOn ? Icons.volume_up : Icons.volume_off;

    return Stack(
      children: [
        // Exit — top-right of safe area.
        Positioned(
          top: padding.top + edgeGap,
          right: padding.right + edgeGap,
          child: CircularIconButton(
            icon: Icons.close,
            diameter: buttonDiameter,
            tooltip: 'Exit',
            onPressed: onExit,
          ),
        ),

        // Forward chevron — cover: right center; spreads: right center.
        if (mode == OverlayChromeMode.cover ||
            mode == OverlayChromeMode.spread)
          Positioned(
            top: padding.top + (safeHeight - buttonDiameter) / 2,
            right: padding.right + edgeGap,
            child: CircularIconButton(
              icon: Icons.chevron_right,
              diameter: buttonDiameter,
              tooltip: 'Next',
              onPressed: onForward,
            ),
          ),

        // Back chevron — spreads: left center; back cover: left bottom band.
        if (mode == OverlayChromeMode.spread)
          Positioned(
            top: padding.top + (safeHeight - buttonDiameter) / 2,
            left: padding.left + edgeGap,
            child: CircularIconButton(
              icon: Icons.chevron_left,
              diameter: buttonDiameter,
              tooltip: 'Back',
              onPressed: onBack,
            ),
          ),

        if (mode == OverlayChromeMode.backCover)
          Positioned(
            top: bottomBandTop,
            left: padding.left + edgeGap,
            child: CircularIconButton(
              icon: Icons.chevron_left,
              diameter: buttonDiameter,
              tooltip: 'Back',
              onPressed: onBack,
            ),
          ),

        // Music — horizontal center, bottom band.
        Positioned(
          top: bottomBandTop,
          left: padding.left + (safeWidth - buttonDiameter) / 2,
          child: CircularIconButton(
            icon: musicIcon,
            diameter: buttonDiameter,
            tooltip: musicOn ? 'Music On' : 'Music Off',
            onPressed: onMusicToggle,
          ),
        ),

        // Restart — back cover only, right bottom band.
        if (mode == OverlayChromeMode.backCover)
          Positioned(
            top: bottomBandTop,
            right: padding.right + edgeGap,
            child: CircularIconButton(
              icon: Icons.replay,
              diameter: buttonDiameter,
              tooltip: 'Restart',
              onPressed: onRestart,
            ),
          ),
      ],
    );
  }
}
