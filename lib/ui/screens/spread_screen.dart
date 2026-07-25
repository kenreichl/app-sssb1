// Landscape spread: artwork + positioned lyric text block.
import 'package:flutter/material.dart';

import '../../models/book_page.dart';
import '../../models/timecode_track.dart';
import '../widgets/fitted_artwork.dart';
import '../widgets/lyric_text_block.dart';

/// One parameterized spread screen (spreads 1–6 share this widget).
class SpreadScreen extends StatelessWidget {
  const SpreadScreen({
    super.key,
    required this.page,
    required this.artRect,
    required this.onArtRect,
    required this.activeLyric,
    required this.musicOn,
    required this.highlighting,
  });

  final SpreadPage page;
  final Rect? artRect;
  final ValueChanged<Rect> onArtRect;
  final ActiveLyric activeLyric;
  final bool musicOn;
  final bool highlighting;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedArtwork(
          imageAsset: page.imageAsset,
          onArtRect: onArtRect,
        ),
        if (artRect != null)
          _PositionedTextBlock(
            artRect: artRect!,
            page: page,
            activeLyric: activeLyric,
            musicOn: musicOn,
            highlighting: highlighting,
          ),
      ],
    );
  }
}

class _PositionedTextBlock extends StatelessWidget {
  const _PositionedTextBlock({
    required this.artRect,
    required this.page,
    required this.activeLyric,
    required this.musicOn,
    required this.highlighting,
  });

  final Rect artRect;
  final SpreadPage page;
  final ActiveLyric activeLyric;
  final bool musicOn;
  final bool highlighting;

  @override
  Widget build(BuildContext context) {
    final block = page.textBlock.toScreenRect(artRect);
    // Animate size changes between spreads (DESIGN §3.4.1).
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: block.left,
      top: block.top,
      width: block.width,
      height: block.height,
      child: LyricTextBlock(
        lyricLines: page.lyricLines,
        timecode: page.timecode,
        activeLyric: activeLyric,
        musicOn: musicOn,
        highlighting: highlighting,
      ),
    );
  }
}
