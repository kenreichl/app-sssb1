// Back-cover scroll: logo → author → illustrator → book_info.
import 'package:flutter/material.dart';

import '../../models/back_cover_content.dart';
import '../../data/book_catalog.dart';
import '../theme/app_theme.dart';

/// Credits content laid out inside the fitted text-block rect.
class BackCoverScroll extends StatelessWidget {
  const BackCoverScroll({
    super.key,
    required this.content,
    required this.blockWidth,
  });

  final BackCoverContent content;
  final double blockWidth;

  @override
  Widget build(BuildContext context) {
    final inset = 0.05 * blockWidth;
    final photoSize = 0.28 * blockWidth;
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final fontSize = AppTheme.lyricFontSize(shortest) * 0.85;
    final style = TextStyle(
      fontFamily: 'Nunito',
      fontSize: fontSize,
      height: 1.35,
      color: AppColors.lyricText,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.textBlockWash),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: inset, vertical: inset),
        child: Column(
          children: [
            // 1. Logo centered.
            Image.asset(
              BookCatalog.imagePath(content.logo),
              height: blockWidth * 0.22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            SizedBox(height: inset),

            // 2. Author photo (circular) + bio.
            _CircularPhoto(
              asset: BookCatalog.imagePath(content.authorPhoto),
              size: photoSize,
            ),
            SizedBox(height: inset * 0.5),
            Text(content.authorBio, style: style, textAlign: TextAlign.center),
            SizedBox(height: inset),

            // 3. Illustrator photo + bio.
            _CircularPhoto(
              asset: BookCatalog.imagePath(content.illustratorPhoto),
              size: photoSize,
            ),
            SizedBox(height: inset * 0.5),
            Text(
              content.illustratorBio,
              style: style,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: inset),

            // 4. Book info.
            Text(content.bookInfo, style: style, textAlign: TextAlign.center),
            SizedBox(height: inset),
          ],
        ),
      ),
    );
  }
}

class _CircularPhoto extends StatelessWidget {
  const _CircularPhoto({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: Colors.black26,
        ),
      ),
    );
  }
}
