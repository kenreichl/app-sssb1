// Sealed page models for the 8-screen book.
import 'back_cover_content.dart';
import 'text_block_rect.dart';
import 'timecode_track.dart';

/// Base type for cover / spread / back-cover pages.
sealed class BookPage {
  const BookPage({
    required this.index,
    required this.imageAsset,
    required this.audioAsset,
  });

  /// Position in the book (0 = cover … 7 = back).
  final int index;

  /// Full asset path, e.g. `assets/images/artwork_spread1.png`.
  final String imageAsset;

  /// Full asset path, e.g. `assets/audio/01_henrietta.mp3`.
  final String audioAsset;

  bool get isPortrait;
  bool get isLandscape => !isPortrait;
}

/// Front cover (portrait): art + looping intro audio, no lyrics.
class CoverPage extends BookPage {
  const CoverPage({
    required super.index,
    required super.imageAsset,
    required super.audioAsset,
  });

  @override
  bool get isPortrait => true;
}

/// One interior spread (landscape): lyrics + timecodes + text block.
class SpreadPage extends BookPage {
  const SpreadPage({
    required super.index,
    required super.imageAsset,
    required super.audioAsset,
    required this.spreadNumber,
    required this.title,
    required this.textBlock,
    required this.lyricLines,
    required this.timecode,
  });

  /// 1–6 as used in asset names.
  final int spreadNumber;
  final String title;
  final TextBlockRect textBlock;

  /// Non-blank lyric lines in order (ids `l1`…); blank lines are stanza gaps.
  /// Each entry is either a lyric string or `null` for a blank stanza spacer.
  final List<String?> lyricLines;
  final TimecodeTrack timecode;

  @override
  bool get isPortrait => false;
}

/// Back cover (portrait): credits scroll + one-shot audio.
class BackCoverPage extends BookPage {
  const BackCoverPage({
    required super.index,
    required super.imageAsset,
    required super.audioAsset,
    required this.content,
  });

  final BackCoverContent content;

  TextBlockRect get textBlock => content.textBlock;

  @override
  bool get isPortrait => true;
}
