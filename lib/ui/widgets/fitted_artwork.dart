// BoxFit.contain artwork with black letterbox; exposes fitted art Rect.
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Centers [imageAsset] with BoxFit.contain and reports the fitted rect.
class FittedArtwork extends StatefulWidget {
  const FittedArtwork({
    super.key,
    required this.imageAsset,
    required this.onArtRect,
    this.onLoadError,
    this.fallback,
  });

  final String imageAsset;

  /// Called whenever layout resolves a new fitted artwork rectangle.
  final ValueChanged<Rect> onArtRect;

  final VoidCallback? onLoadError;

  /// Optional widget when the image fails (cover fallback, etc.).
  final Widget? fallback;

  @override
  State<FittedArtwork> createState() => _FittedArtworkState();
}

class _FittedArtworkState extends State<FittedArtwork> {
  Rect? _lastReported;
  bool _failed = false;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void dispose() {
    _detachListener();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FittedArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageAsset != widget.imageAsset) {
      _lastReported = null;
      _failed = false;
    }
  }

  void _detachListener() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _resolveArtRect(BoxConstraints constraints) {
    _detachListener();
    final stream = AssetImage(widget.imageAsset).resolve(ImageConfiguration(
      bundle: DefaultAssetBundle.of(context),
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    ));
    _stream = stream;
    _listener = ImageStreamListener((info, _) {
      final iw = info.image.width.toDouble();
      final ih = info.image.height.toDouble();
      final bw = constraints.maxWidth;
      final bh = constraints.maxHeight;
      if (iw <= 0 || ih <= 0 || bw <= 0 || bh <= 0) return;
      final scale = (bw / iw < bh / ih) ? bw / iw : bh / ih;
      final w = iw * scale;
      final h = ih * scale;
      final rect = Rect.fromLTWH((bw - w) / 2, (bh - h) / 2, w, h);
      if (_lastReported == rect) return;
      _lastReported = rect;
      widget.onArtRect(rect);
    }, onError: (exception, stackTrace) {
      if (!_failed) {
        _failed = true;
        widget.onLoadError?.call();
      }
    });
    stream.addListener(_listener!);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.letterbox,
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _resolveArtRect(constraints);
          });
          return Image.asset(
            widget.imageAsset,
            fit: BoxFit.contain,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              if (!_failed) {
                _failed = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.onLoadError?.call();
                });
              }
              return widget.fallback ??
                  const Center(
                    child: Text(
                      'Image unavailable',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
            },
          );
        },
      ),
    );
  }
}
