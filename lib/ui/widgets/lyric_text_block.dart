// Scrollable lyric block with word highlight + autoscroll.
import 'package:flutter/material.dart';

import '../../models/lyric_line.dart';
import '../../models/timecode_track.dart';
import '../theme/app_theme.dart';

/// White wash text block positioned by parent; highlights active word.
class LyricTextBlock extends StatefulWidget {
  const LyricTextBlock({
    super.key,
    required this.lyricLines,
    required this.timecode,
    required this.activeLyric,
    required this.musicOn,
    required this.highlighting,
  });

  /// Non-blank lyric strings + null stanza spacers.
  final List<String?> lyricLines;
  final TimecodeTrack timecode;
  final ActiveLyric activeLyric;
  final bool musicOn;
  final bool highlighting;

  @override
  State<LyricTextBlock> createState() => _LyricTextBlockState();
}

class _LyricTextBlockState extends State<LyricTextBlock> {
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  DateTime? _manualScrollUntil;
  String? _lastAutoscrollLineId;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LyricTextBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlighting &&
        widget.activeLyric.lineId != null &&
        widget.activeLyric.lineId != _lastAutoscrollLineId) {
      _maybeAutoscroll(widget.activeLyric.lineId!);
    }
    if (!widget.highlighting) {
      _lastAutoscrollLineId = null;
    }
  }

  void _onUserScroll() {
    // Manual scroll pauses autoscroll for 2 seconds (UX §5).
    _manualScrollUntil = DateTime.now().add(const Duration(seconds: 2));
  }

  void _maybeAutoscroll(String lineId) {
    final paused = _manualScrollUntil != null &&
        DateTime.now().isBefore(_manualScrollUntil!);
    if (paused) return;

    // Map lineId (l1…) to the index among non-null lyric lines.
    var nonBlankIndex = 0;
    int? visualIndex;
    for (var i = 0; i < widget.lyricLines.length; i++) {
      final text = widget.lyricLines[i];
      if (text == null) continue;
      nonBlankIndex++;
      if ('l$nonBlankIndex' == lineId) {
        visualIndex = i;
        break;
      }
    }
    if (visualIndex == null) return;
    final key = _lineKeys[visualIndex];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    _lastAutoscrollLineId = lineId;
    // Keep active line near upper-middle of the viewport.
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.3,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final fontSize = AppTheme.lyricFontSize(shortest);
    final baseStyle = TextStyle(
      fontFamily: 'Nunito',
      fontSize: fontSize,
      height: 1.35,
      color: AppColors.lyricText,
      fontWeight: FontWeight.w400,
    );
    final activeStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.highlight,
    );

    // Build id → line lookup from timecode for word-level spans.
    final byId = <String, LyricLine>{
      for (final line in widget.timecode.lines) line.id: line,
    };

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.textBlockWash,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification && n.dragDetails != null) {
            _onUserScroll();
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.lyricLines.length; i++)
                _buildLine(i, byId, baseStyle, activeStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(
    int visualIndex,
    Map<String, LyricLine> byId,
    TextStyle baseStyle,
    TextStyle activeStyle,
  ) {
    final text = widget.lyricLines[visualIndex];
    if (text == null) {
      return SizedBox(height: baseStyle.fontSize! * 0.8);
    }

    // Count non-blank lines up to here for lN id.
    var nonBlank = 0;
    for (var i = 0; i <= visualIndex; i++) {
      if (widget.lyricLines[i] != null) nonBlank++;
    }
    final lineId = 'l$nonBlank';
    final key = _lineKeys.putIfAbsent(visualIndex, GlobalKey.new);
    final timed = byId[lineId];
    final isActiveLine =
        widget.highlighting && widget.activeLyric.lineId == lineId;

    Widget child;
    if (timed == null || timed.words.isEmpty || !widget.highlighting) {
      child = Text(text, style: baseStyle);
    } else {
      final spans = <InlineSpan>[];
      for (var wi = 0; wi < timed.words.length; wi++) {
        final w = timed.words[wi];
        final active = isActiveLine && widget.activeLyric.wordIndex == wi;
        spans.add(TextSpan(
          text: wi == 0 ? w.text : ' ${w.text}',
          style: active ? activeStyle : baseStyle,
        ));
      }
      child = Text.rich(TextSpan(children: spans));
    }

    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isActiveLine ? 2 : 0),
      color: isActiveLine
          ? AppColors.highlight.withValues(alpha: 0.10)
          : Colors.transparent,
      child: child,
    );
  }
}
