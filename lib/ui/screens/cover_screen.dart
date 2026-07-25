// Front cover: fitted art + optional image-load fallback.
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/fitted_artwork.dart';

/// Portrait cover page body (chrome is owned by BookShell).
class CoverScreen extends StatelessWidget {
  const CoverScreen({
    super.key,
    required this.imageAsset,
    required this.onArtRect,
    this.showFallback = false,
    this.onImageError,
    this.onContinueFromFallback,
  });

  final String imageAsset;
  final ValueChanged<Rect> onArtRect;
  final bool showFallback;
  final VoidCallback? onImageError;
  final VoidCallback? onContinueFromFallback;

  @override
  Widget build(BuildContext context) {
    if (showFallback) {
      return ColoredBox(
        color: AppColors.letterbox,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sunny Side Songs',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Back to the Garden',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              if (onContinueFromFallback != null)
                FilledButton(
                  onPressed: onContinueFromFallback,
                  child: const Text('Continue'),
                ),
            ],
          ),
        ),
      );
    }

    return FittedArtwork(
      imageAsset: imageAsset,
      onArtRect: onArtRect,
      onLoadError: onImageError,
      fallback: const SizedBox.shrink(),
    );
  }
}
