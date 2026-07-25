// Parsed timecode JSON for one spread (hybrid line/word schema).
import 'lyric_line.dart';

/// Result of resolving the active word/line at playback time [t].
class ActiveLyric {
  const ActiveLyric({
    this.lineId,
    this.wordIndex,
    this.lineIndex,
  });

  final String? lineId;
  final int? wordIndex;
  final int? lineIndex;

  static const empty = ActiveLyric();

  bool get hasHighlight => lineId != null && wordIndex != null;
}

/// Full track loaded from `timecode_spreadN.json`.
class TimecodeTrack {
  const TimecodeTrack({
    required this.song,
    required this.duration,
    required this.lines,
  });

  final String song;
  final double duration;
  final List<LyricLine> lines;

  factory TimecodeTrack.fromJson(Map<String, dynamic> json) {
    final rawLines =
        (json['lines'] as List<dynamic>).cast<Map<String, dynamic>>();
    return TimecodeTrack(
      song: json['song'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      lines: rawLines.map(LyricLine.fromJson).toList(),
    );
  }

  /// Active word at time [t]: first word where start <= t < end
  /// (inclusive end on the last word of the track).
  ActiveLyric activeAt(double t) {
    if (lines.isEmpty || t < 0) {
      return ActiveLyric.empty;
    }

    for (var li = 0; li < lines.length; li++) {
      final line = lines[li];
      final words = line.words;
      if (words.isEmpty) {
        if (line.containsTime(t)) {
          return ActiveLyric(lineId: line.id, lineIndex: li, wordIndex: null);
        }
        continue;
      }
      for (var wi = 0; wi < words.length; wi++) {
        final isLastWord = li == lines.length - 1 && wi == words.length - 1;
        if (words[wi].containsTime(t, isLastWord: isLastWord)) {
          return ActiveLyric(
            lineId: line.id,
            lineIndex: li,
            wordIndex: wi,
          );
        }
      }
    }
    return ActiveLyric.empty;
  }
}
