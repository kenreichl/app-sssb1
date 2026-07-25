// Page-turn host: fade-via-black and soft curl between spreads.
import 'package:flutter/material.dart';

/// Kind of transition driven by BookShell.
enum PageTurnKind {
  /// Cover↔spread1, spread6↔back, back→cover restart.
  fadeViaBlack,

  /// Spread↔spread soft horizontal curl ≤1200 ms.
  softCurl,
}

/// Runs the outgoing/incoming animation and reports completion.
class PageTransitionHost extends StatefulWidget {
  const PageTransitionHost({
    super.key,
    required this.child,
    required this.transitionNonce,
    required this.kind,
    required this.forward,
    required this.onFadeMidpoint,
    required this.onComplete,
    this.hideChrome = false,
  });

  final Widget child;

  /// Bumped by parent to start a new transition.
  final int transitionNonce;
  final PageTurnKind kind;
  final bool forward;

  /// Called at black midpoint (fade) or mid-curl — swap page content / orientation.
  final VoidCallback onFadeMidpoint;
  final VoidCallback onComplete;
  final bool hideChrome;

  @override
  State<PageTransitionHost> createState() => _PageTransitionHostState();
}

class _PageTransitionHostState extends State<PageTransitionHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _lastNonce = 0;
  bool _midpointFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(_onTick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
        _controller.value = 0;
        _midpointFired = false;
      }
    });
  }

  @override
  void didUpdateWidget(covariant PageTransitionHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transitionNonce != _lastNonce && widget.transitionNonce > 0) {
      _lastNonce = widget.transitionNonce;
      _midpointFired = false;
      final duration = widget.kind == PageTurnKind.fadeViaBlack
          ? const Duration(milliseconds: 400) // 200 out + 200 in
          : const Duration(milliseconds: 900); // soft curl under 1200 ms
      _controller.duration = duration;
      _controller.forward(from: 0);
    }
  }

  void _onTick() {
    if (_midpointFired) return;
    if (_controller.value >= 0.5) {
      _midpointFired = true;
      widget.onFadeMidpoint();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating && _controller.value == 0) {
          return child!;
        }
        if (widget.kind == PageTurnKind.fadeViaBlack) {
          // 0→0.5 fade to black, 0.5→1 fade from black.
          final t = _controller.value;
          final blackOpacity = t < 0.5 ? t * 2 : (1 - t) * 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              child!,
              IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: blackOpacity.clamp(0, 1)),
                ),
              ),
            ],
          );
        }

        // Soft curl illusion: slight perspective + horizontal slide.
        final t = _controller.value;
        final dir = widget.forward ? -1.0 : 1.0;
        // First half: old page peels; second half: new page settles.
        final slide = t < 0.5 ? dir * t * 0.35 : dir * (1 - t) * 0.35;
        final curl = (t < 0.5 ? t : 1 - t) * 0.12;
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(curl * dir)
                ..translateByDouble(
                  slide * MediaQuery.sizeOf(context).width,
                  0,
                  0,
                  1,
                ),
              child: child,
            ),
            // Soft vignette during curl.
            IgnorePointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: curl * 0.5),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
