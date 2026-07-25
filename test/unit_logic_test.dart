// Unit tests: active word lookup, nav edges, text-block mapping, music pref.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_sssb1/models/text_block_rect.dart';
import 'package:app_sssb1/models/timecode_track.dart';
import 'package:app_sssb1/state/book_navigator.dart';
import 'package:app_sssb1/state/music_preference.dart';

void main() {
  group('TimecodeTrack.activeAt', () {
    late TimecodeTrack track;

    setUp(() {
      track = TimecodeTrack.fromJson({
        'song': 'test',
        'duration': 10.0,
        'lines': [
          {
            'id': 'l1',
            'start': 1.0,
            'end': 3.0,
            'text': 'Hello world',
            'words': [
              {'start': 1.0, 'end': 2.0, 'text': 'Hello'},
              {'start': 2.0, 'end': 3.0, 'text': 'world'},
            ],
          },
          {
            'id': 'l2',
            'start': 4.0,
            'end': 6.0,
            'text': 'Again',
            'words': [
              {'start': 4.0, 'end': 6.0, 'text': 'Again'},
            ],
          },
        ],
      });
    });

    test('highlights first word in range', () {
      final a = track.activeAt(1.5);
      expect(a.lineId, 'l1');
      expect(a.wordIndex, 0);
    });

    test('highlights second word', () {
      final a = track.activeAt(2.5);
      expect(a.lineId, 'l1');
      expect(a.wordIndex, 1);
    });

    test('gap between lines → no highlight', () {
      final a = track.activeAt(3.5);
      expect(a.hasHighlight, isFalse);
    });

    test('before song → no highlight', () {
      expect(track.activeAt(0.2).hasHighlight, isFalse);
    });

    test('inclusive end on last word', () {
      final a = track.activeAt(6.0);
      expect(a.lineId, 'l2');
      expect(a.wordIndex, 0);
    });
  });

  group('TextBlockRect.toScreenRect', () {
    test('maps normalized block onto art rect', () {
      const block = TextBlockRect(x: 0.1, y: 0.2, width: 0.5, height: 0.4);
      const art = Rect.fromLTWH(100, 50, 200, 100);
      final screen = block.toScreenRect(art);
      expect(screen.left, closeTo(120, 0.001)); // 100 + 0.1*200
      expect(screen.top, closeTo(70, 0.001)); // 50 + 0.2*100
      expect(screen.width, closeTo(100, 0.001)); // 0.5*200
      expect(screen.height, closeTo(40, 0.001)); // 0.4*100
    });
  });

  group('BookNavigator edges', () {
    test('cannot go back from cover', () {
      final nav = BookNavigator();
      expect(nav.canGoBack, isFalse);
      expect(nav.canGoForward, isTrue);
    });

    test('cannot go forward from back cover', () {
      final nav = BookNavigator();
      nav.beginTransition();
      nav.completeTransition(7);
      expect(nav.canGoForward, isFalse);
      expect(nav.canGoBack, isTrue);
    });

    test('ignores navigation while transitioning', () {
      final nav = BookNavigator();
      expect(nav.beginTransition(), isTrue);
      expect(nav.beginTransition(), isFalse);
      expect(nav.canGoForward, isFalse);
      nav.endTransition();
      expect(nav.canGoForward, isTrue);
    });
  });

  group('MusicPreference', () {
    test('defaults to true and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final pref = MusicPreference();
      await pref.load();
      expect(pref.musicOn, isTrue);

      await pref.setMusicOn(false);
      expect(pref.musicOn, isFalse);

      final pref2 = MusicPreference();
      await pref2.load();
      expect(pref2.musicOn, isFalse);
    });
  });
}
