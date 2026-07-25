// Lyric word / line models used by highlighting.
/// A single timed word inside a lyric line.
class LyricWord {
  const LyricWord({
    required this.start,
    required this.end,
    required this.text,
  });

  final double start;
  final double end;
  final String text;

  /// Active when start <= t < end (inclusive end allowed for the last word).
  bool containsTime(double t, {required bool isLastWord}) {
    if (isLastWord) {
      return t >= start && t <= end;
    }
    return t >= start && t < end;
  }

  factory LyricWord.fromJson(Map<String, dynamic> json) {
    return LyricWord(
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
    );
  }
}

/// One lyric line (`l1`, `l2`, …) with optional word timings.
class LyricLine {
  const LyricLine({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.words,
  });

  final String id;
  final double start;
  final double end;
  final String text;
  final List<LyricWord> words;

  bool containsTime(double t) => t >= start && t < end;

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    final rawWords = (json['words'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return LyricLine(
      id: json['id'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
      words: rawWords.map(LyricWord.fromJson).toList(),
    );
  }
}
