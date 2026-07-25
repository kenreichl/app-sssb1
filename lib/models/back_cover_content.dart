// Parsed back-cover markdown (bios + book info + asset refs).
import 'text_block_rect.dart';

/// Structured content for the back-cover scroll block.
class BackCoverContent {
  const BackCoverContent({
    required this.illustration,
    required this.audio,
    required this.logo,
    required this.authorPhoto,
    required this.illustratorPhoto,
    required this.textBlock,
    required this.authorBio,
    required this.illustratorBio,
    required this.bookInfo,
  });

  final String illustration;
  final String audio;
  final String logo;
  final String authorPhoto;
  final String illustratorPhoto;
  final TextBlockRect textBlock;
  final String authorBio;
  final String illustratorBio;
  final String bookInfo;
}
