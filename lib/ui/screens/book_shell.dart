// Hosts the 8-page book: orientation, transitions, audio, chrome.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/book_catalog.dart';
import '../../data/content_loader.dart';
import '../../models/book_page.dart';
import '../../models/timecode_track.dart';
import '../../state/audio_controller.dart';
import '../../state/book_navigator.dart';
import '../../state/music_preference.dart';
import '../theme/app_theme.dart';
import '../widgets/overlay_controls.dart';
import '../widgets/page_transition_host.dart';
import 'back_cover_screen.dart';
import 'cover_screen.dart';
import 'spread_screen.dart';

/// Root reading UI: loads content, wires state, owns page-turn + audio lifecycle.
class BookShell extends StatefulWidget {
  const BookShell({super.key});

  @override
  State<BookShell> createState() => _BookShellState();
}

class _BookShellState extends State<BookShell> with WidgetsBindingObserver {
  final _loader = ContentLoader();
  final _music = MusicPreference();
  final _audio = AudioController();
  final _nav = BookNavigator();

  List<BookPage>? _pages;
  Object? _loadError;
  Rect? _artRect;
  bool _coverImageFailed = false;
  bool _chromeVisible = true;
  bool _highlighting = false;

  int _transitionNonce = 0;
  PageTurnKind _turnKind = PageTurnKind.fadeViaBlack;
  bool _turnForward = true;
  int? _pendingIndex;
  bool _awaitingMidpoint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _music.load();
      await _audio.init();
      final pages = await _loader.loadBook();
      if (!mounted) return;
      setState(() => _pages = pages);
      _music.addListener(_onMusicPreferenceChanged);
      _audio.addListener(_onAudioTick);
      // Cover music starts ~200 ms after init if preference On (DESIGN §3.4.2).
      await _startPageAudio(
        pages[BookCatalog.coverIndex],
        delay: const Duration(milliseconds: 200),
      );
      _preloadAdjacent(0);
    } catch (e, st) {
      debugPrint('Book load failed: $e\n$st');
      if (mounted) setState(() => _loadError = e);
    }
  }

  void _onMusicPreferenceChanged() {
    // Preference listener alone does not start/stop; toggle handler does.
    if (mounted) setState(() {});
  }

  void _onAudioTick() {
    if (!mounted) return;
    // Rebuild so LyricTextBlock sees latest activeLyric.
    // Clear highlight session when playback completes naturally.
    if (_highlighting && !_audio.isPlaying && _audio.activeLyric.hasHighlight == false) {
      setState(() => _highlighting = false);
    } else {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App backgrounded → stop audio; clear highlight; keep preference.
    // Use paused/detached only — inactive fires during orientation changes.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audio.stopImmediate(clearHighlight: true);
      if (mounted) setState(() => _highlighting = false);
    }
  }

  BookPage get _current {
    final pages = _pages!;
    return pages[_nav.index];
  }

  OverlayChromeMode get _chromeMode {
    final page = _current;
    return switch (page) {
      CoverPage() => OverlayChromeMode.cover,
      SpreadPage() => OverlayChromeMode.spread,
      BackCoverPage() => OverlayChromeMode.backCover,
    };
  }

  Future<void> _setOrientationForIndex(int index) async {
    if (BookCatalog.isLandscapeIndex(index)) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  Duration _transitionDuration(PageTurnKind kind) {
    return kind == PageTurnKind.fadeViaBlack
        ? const Duration(milliseconds: 400)
        : const Duration(milliseconds: 900);
  }

  PageTurnKind _kindFor(int from, int to) {
    // Fade via black for cover↔spread1, spread6↔back, back→cover.
    final coverSpread = (from == 0 && to == 1) || (from == 1 && to == 0);
    final spreadBack = (from == 6 && to == 7) || (from == 7 && to == 6);
    final restart = from == 7 && to == 0;
    if (coverSpread || spreadBack || restart) {
      return PageTurnKind.fadeViaBlack;
    }
    return PageTurnKind.softCurl;
  }

  Future<void> _goTo(int target) async {
    if (!_nav.beginTransition()) return;
    final from = _nav.index;
    final kind = _kindFor(from, target);
    final duration = _transitionDuration(kind);

    setState(() {
      _chromeVisible = false;
      _turnKind = kind;
      _turnForward = target > from;
      _pendingIndex = target;
      _awaitingMidpoint = true;
      _artRect = null;
      _highlighting = false;
      _transitionNonce++;
    });

    // Fade current audio so it finishes by transition end.
    // Don't await fully in parallel with UI — kick off and let transition run.
    // ignore: unawaited_futures
    _audio.fadeOutForPageTurn(duration);
  }

  void _onTransitionMidpoint() {
    if (!_awaitingMidpoint) return;
    final target = _pendingIndex;
    if (target == null) return;
    _awaitingMidpoint = false;

    // Orientation locks at fade-in start (DESIGN §3.4.1).
    _setOrientationForIndex(target);

    setState(() {
      // Swap page content while keep chevrons locked until animation ends.
      _nav.setIndexDuringTransition(target);
      _artRect = null;
      _coverImageFailed = false;
    });
  }

  Future<void> _onTransitionComplete() async {
    final pages = _pages;
    if (pages == null) return;

    _nav.endTransition();

    setState(() {
      _chromeVisible = true;
      _pendingIndex = null;
    });

    _preloadAdjacent(_nav.index);
    await _startPageAudio(
      pages[_nav.index],
      delay: const Duration(milliseconds: 50),
    );
  }

  Future<void> _startPageAudio(BookPage page, {required Duration delay}) async {
    if (!_music.musicOn) {
      setState(() => _highlighting = false);
      return;
    }

    final loop = page is CoverPage
        ? AudioLoopPolicy.coverThreeLoops
        : AudioLoopPolicy.playOnce;
    final TimecodeTrack? timecode =
        page is SpreadPage ? page.timecode : null;

    await _audio.playPage(
      assetPath: page.audioAsset,
      loopPolicy: loop,
      timecode: timecode,
      startDelay: delay,
    );
    if (mounted) {
      setState(() => _highlighting = page is SpreadPage);
    }
  }

  Future<void> _onMusicToggle() async {
    final turningOff = _music.musicOn;
    if (turningOff) {
      // Music Off: 1s fade, clear highlight, keep scroll offset.
      await _music.setMusicOn(false);
      await _audio.fadeOut(
        duration: const Duration(seconds: 1),
        clearHighlight: true,
      );
      if (mounted) setState(() => _highlighting = false);
    } else {
      await _music.setMusicOn(true);
      // Music On: start current page audio from 0 + highlight.
      final pages = _pages;
      if (pages != null) {
        await _startPageAudio(pages[_nav.index], delay: Duration.zero);
      }
    }
  }

  Future<void> _onExit() async {
    if (_music.musicOn && _audio.isPlaying) {
      await _audio.fadeOut(duration: const Duration(seconds: 1));
    }
    // Android: leave task; iOS: SystemNavigator.pop (no guaranteed kill).
    await SystemNavigator.pop();
  }

  void _preloadAdjacent(int index) {
    final pages = _pages;
    if (pages == null || !mounted) return;
    final candidates = <int>[index - 1, index + 1];
    for (final i in candidates) {
      if (i < 0 || i >= pages.length) continue;
      precacheImage(AssetImage(pages[i].imageAsset), context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _music.removeListener(_onMusicPreferenceChanged);
    _audio.removeListener(_onAudioTick);
    _audio.dispose();
    _music.dispose();
    _nav.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.letterbox,
        body: Center(
          child: Text(
            'Could not load book.\n$_loadError',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final pages = _pages;
    if (pages == null) {
      return const Scaffold(
        backgroundColor: AppColors.letterbox,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final page = pages[_nav.index];

    return Scaffold(
      backgroundColor: AppColors.letterbox,
      body: PageTransitionHost(
        transitionNonce: _transitionNonce,
        kind: _turnKind,
        forward: _turnForward,
        onFadeMidpoint: _onTransitionMidpoint,
        onComplete: () {
          // Fire-and-forget async completion.
          _onTransitionComplete();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPageBody(page),
            OverlayControls(
              mode: _chromeMode,
              musicOn: _music.musicOn,
              visible: _chromeVisible,
              onExit: _onExit,
              onMusicToggle: _onMusicToggle,
              onForward: _nav.canGoForward
                  ? () => _goTo(_nav.index + 1)
                  : null,
              onBack:
                  _nav.canGoBack ? () => _goTo(_nav.index - 1) : null,
              onRestart: page is BackCoverPage
                  ? () => _goTo(BookCatalog.coverIndex)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageBody(BookPage page) {
    return switch (page) {
      CoverPage(:final imageAsset) => CoverScreen(
          imageAsset: imageAsset,
          onArtRect: (r) => setState(() => _artRect = r),
          showFallback: _coverImageFailed,
          onImageError: () {
            if (!_coverImageFailed) {
              setState(() => _coverImageFailed = true);
            }
          },
          onContinueFromFallback: () => _goTo(BookCatalog.firstSpreadIndex),
        ),
      SpreadPage() => SpreadScreen(
          page: page,
          artRect: _artRect,
          onArtRect: (r) {
            if (_artRect != r) setState(() => _artRect = r);
          },
          activeLyric: _audio.activeLyric,
          musicOn: _music.musicOn,
          highlighting: _highlighting && _music.musicOn,
        ),
      BackCoverPage() => BackCoverScreen(
          page: page,
          artRect: _artRect,
          onArtRect: (r) {
            if (_artRect != r) setState(() => _artRect = r);
          },
        ),
    };
  }
}
