// Back cover: artwork + credits scroll in text_block rect.
import 'package:flutter/material.dart';

import '../../models/book_page.dart';
import '../widgets/back_cover_scroll.dart';
import '../widgets/fitted_artwork.dart';

/// Portrait back-cover body (chrome owned by BookShell).
class BackCoverScreen extends StatelessWidget {
  const BackCoverScreen({
    super.key,
    required this.page,
    required this.artRect,
    required this.onArtRect,
  });

  final BackCoverPage page;
  final Rect? artRect;
  final ValueChanged<Rect> onArtRect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedArtwork(
          imageAsset: page.imageAsset,
          onArtRect: onArtRect,
        ),
        if (artRect != null) ...[
          Builder(
            builder: (context) {
              final block = page.textBlock.toScreenRect(artRect!);
              return Positioned(
                left: block.left,
                top: block.top,
                width: block.width,
                height: block.height,
                child: BackCoverScroll(
                  content: page.content,
                  blockWidth: block.width,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
