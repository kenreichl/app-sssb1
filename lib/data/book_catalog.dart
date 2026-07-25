// Ordered list of 8 pages + asset path helpers.
/// Central place for asset path conventions used across loaders and UI.
class BookCatalog {
  BookCatalog._();

  static const int pageCount = 8;
  static const int coverIndex = 0;
  static const int firstSpreadIndex = 1;
  static const int lastSpreadIndex = 6;
  static const int backCoverIndex = 7;

  static const String imagesPrefix = 'assets/images/';
  static const String audioPrefix = 'assets/audio/';
  static const String dataPrefix = 'assets/data/';

  static String imagePath(String fileName) => '$imagesPrefix$fileName';
  static String audioPath(String fileName) => '$audioPrefix$fileName';
  static String dataPath(String fileName) => '$dataPrefix$fileName';

  static String coverFrontImage = imagePath('artwork_cover_front.jpg');
  static String coverFrontAudio =
      audioPath('00_cover_front_five_little_green_beans.mp3');

  static String coverBackImage = imagePath('artwork_cover_back.jpg');
  static String coverBackAudio = audioPath('07_cover_back_twinkle.mp3');
  static String coverBackMarkdown = dataPath('text_cover_back.md');

  static String spreadImage(int n) => imagePath('artwork_spread$n.png');
  static String spreadMarkdown(int n) => dataPath('text_spread$n.md');
  static String spreadTimecode(int n) => dataPath('timecode_spread$n.json');

  /// True for indices that need landscape lock (spreads 1–6).
  static bool isLandscapeIndex(int index) =>
      index >= firstSpreadIndex && index <= lastSpreadIndex;
}
