// Single JustAudio player: fade, loop policy, cancel-on-navigate.
import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/timecode_track.dart';

/// How the current page should treat end-of-track looping.
enum AudioLoopPolicy {
  /// Cover: loop exactly 3 times, then stay silent (preference stays On).
  coverThreeLoops,
  /// Spreads / back: play once.
  playOnce,
}

/// Owns the one app-wide audio player and highlight time source.
class AudioController extends ChangeNotifier {
  AudioController();

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<void>? _interruptionSub;

  ActiveLyric _active = ActiveLyric.empty;
  TimecodeTrack? _timecode;
  String? _currentAsset;
  int _generation = 0;
  bool _fading = false;
  bool _disposed = false;

  ActiveLyric get activeLyric => _active;
  Duration get position => _player.position;
  bool get isPlaying => _player.playing;
  String? get currentAsset => _currentAsset;

  /// Wire audio session interruptions → stop + clear highlight.
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // When OS interrupts (call / headphones), stop cleanly.
    await session.setActive(true);
    _interruptionSub = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        stopImmediate(clearHighlight: true);
      }
    });

    // Becoming noisy (unplug) also stops playback.
    session.becomingNoisyEventStream.listen((_) {
      stopImmediate(clearHighlight: true);
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _clearHighlight();
        notifyListeners();
      }
    });
  }

  /// Start page audio after optional delay. Cancels any in-flight start.
  Future<void> playPage({
    required String assetPath,
    required AudioLoopPolicy loopPolicy,
    TimecodeTrack? timecode,
    Duration startDelay = Duration.zero,
  }) async {
    final gen = ++_generation;
    await _cancelFade();
    await _player.stop();
    _clearHighlight();
    _timecode = timecode;
    _currentAsset = assetPath;
    notifyListeners();

    if (startDelay > Duration.zero) {
      await Future<void>.delayed(startDelay);
      if (gen != _generation || _disposed) return;
    }

    try {
      await _player.setVolume(1.0);

      if (loopPolicy == AudioLoopPolicy.coverThreeLoops) {
        // Play the cover track exactly 3 times, then stop (no infinite loop).
        await _player.setAudioSources(
          List.generate(3, (_) => AudioSource.asset(assetPath)),
        );
        await _player.setLoopMode(LoopMode.off);
      } else {
        await _player.setAsset(assetPath);
        await _player.setLoopMode(LoopMode.off);
      }

      if (gen != _generation || _disposed) return;
      await _player.seek(Duration.zero);
      await _player.play();
      _listenPosition(gen);
    } catch (e, st) {
      // Missing / failed audio → silent; UI stays usable.
      debugPrint('Audio load failed for $assetPath: $e\n$st');
      _currentAsset = null;
      _clearHighlight();
      notifyListeners();
    }
  }

  void _listenPosition(int gen) {
    _positionSub?.cancel();
    _positionSub = _player.positionStream.listen((pos) {
      if (gen != _generation) return;
      final track = _timecode;
      if (track == null) {
        if (_active.hasHighlight) {
          _clearHighlight();
          notifyListeners();
        }
        return;
      }
      final next = track.activeAt(pos.inMilliseconds / 1000.0);
      if (next.lineId != _active.lineId ||
          next.wordIndex != _active.wordIndex ||
          next.lineIndex != _active.lineIndex) {
        _active = next;
        notifyListeners();
      }
    });
  }

  /// Fade out over [duration], then stop. Used for Music Off and Exit.
  Future<void> fadeOut({
    Duration duration = const Duration(seconds: 1),
    bool clearHighlight = true,
  }) async {
    final gen = _generation;
    _fading = true;
    final steps = 20;
    final stepMs = duration.inMilliseconds ~/ steps;
    final startVol = _player.volume;
    try {
      for (var i = 1; i <= steps; i++) {
        if (gen != _generation || _disposed) return;
        await _player.setVolume(startVol * (1 - i / steps));
        await Future<void>.delayed(Duration(milliseconds: stepMs));
      }
      if (gen != _generation || _disposed) return;
      await _player.stop();
      await _player.setVolume(1.0);
    } finally {
      _fading = false;
      if (clearHighlight) _clearHighlight();
      notifyListeners();
    }
  }

  /// Fade out timed to finish by [transitionDuration] (page leave).
  /// Edge case: if remaining song time < 1200 ms, hard-stop (no fade).
  Future<void> fadeOutForPageTurn(Duration transitionDuration) async {
    final gen = ++_generation;
    _positionSub?.cancel();

    final duration = _player.duration;
    final remaining =
        duration == null ? null : duration - _player.position;

    // DESIGN §3.4.2: last 1200 ms of song → no fade.
    if (remaining != null && remaining <= const Duration(milliseconds: 1200)) {
      await _player.stop();
      _clearHighlight();
      notifyListeners();
      return;
    }

    final fadeFor = transitionDuration;
    _fading = true;
    final steps = 12;
    final stepMs = (fadeFor.inMilliseconds ~/ steps).clamp(1, 100);
    final startVol = _player.volume;
    try {
      for (var i = 1; i <= steps; i++) {
        if (_disposed) return;
        // Allow new playPage to bump generation mid-fade.
        if (gen != _generation && i > 1) {
          // Still finish stopping this player instance path.
        }
        await _player.setVolume(startVol * (1 - i / steps));
        await Future<void>.delayed(Duration(milliseconds: stepMs));
      }
      await _player.stop();
      await _player.setVolume(1.0);
    } finally {
      _fading = false;
      _clearHighlight();
      notifyListeners();
    }
  }

  /// Hard stop (interruptions / app pause).
  Future<void> stopImmediate({bool clearHighlight = true}) async {
    _generation++;
    await _cancelFade();
    await _player.stop();
    if (clearHighlight) _clearHighlight();
    notifyListeners();
  }

  Future<void> _cancelFade() async {
    // Bumping generation abandons in-flight fade loops.
    if (_fading) {
      _generation++;
      _fading = false;
    }
  }

  void _clearHighlight() {
    _active = ActiveLyric.empty;
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _interruptionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
