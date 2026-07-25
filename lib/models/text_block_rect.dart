// Normalized text-block rectangle relative to fitted artwork (0–1).
import 'dart:ui';

/// Frontmatter `text_block: {x,y,width,height}` in fraction of fitted art.
class TextBlockRect {
  const TextBlockRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  /// Maps this normalized block onto the letterboxed artwork [artRect].
  Rect toScreenRect(Rect artRect) {
    return Rect.fromLTWH(
      artRect.left + x * artRect.width,
      artRect.top + y * artRect.height,
      width * artRect.width,
      height * artRect.height,
    );
  }

  /// True when all values are in the expected 0–1 range (inclusive).
  bool get isValidNormalized =>
      x >= 0 &&
      y >= 0 &&
      width > 0 &&
      height > 0 &&
      x + width <= 1.0001 &&
      y + height <= 1.0001;

  factory TextBlockRect.fromYamlMap(Map<dynamic, dynamic> map) {
    return TextBlockRect(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }
}
