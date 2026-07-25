// Current page index + transition lock for chevron navigation.
import 'package:flutter/foundation.dart';

import '../data/book_catalog.dart';

/// Owns book page index (0..7) and blocks re-entry during transitions.
class BookNavigator extends ChangeNotifier {
  BookNavigator({this.pageCount = BookCatalog.pageCount});

  final int pageCount;

  int _index = BookCatalog.coverIndex;
  bool _transitioning = false;

  int get index => _index;
  bool get isTransitioning => _transitioning;
  bool get canGoBack => _index > 0 && !_transitioning;
  bool get canGoForward => _index < pageCount - 1 && !_transitioning;
  bool get isCover => _index == BookCatalog.coverIndex;
  bool get isBackCover => _index == BookCatalog.backCoverIndex;
  bool get isSpread => BookCatalog.isLandscapeIndex(_index);

  /// Begin a locked transition; returns false if already transitioning.
  bool beginTransition() {
    if (_transitioning) return false;
    _transitioning = true;
    notifyListeners();
    return true;
  }

  /// Swap visible page mid-animation while keeping the transition lock.
  void setIndexDuringTransition(int newIndex) {
    _index = newIndex.clamp(0, pageCount - 1);
    notifyListeners();
  }

  /// Clear the transition lock after the animation finishes.
  void endTransition() {
    _transitioning = false;
    notifyListeners();
  }

  /// Commit the new index and clear the transition lock.
  void completeTransition(int newIndex) {
    _index = newIndex.clamp(0, pageCount - 1);
    _transitioning = false;
    notifyListeners();
  }

  /// Abort lock without changing index (rare failure path).
  void cancelTransition() {
    _transitioning = false;
    notifyListeners();
  }
}
