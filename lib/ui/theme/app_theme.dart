// App colors, Nunito typography, and Material theme.
import 'package:flutter/material.dart';

/// Visual tokens from DESIGN §3.5 / §3.7.
class AppColors {
  AppColors._();

  /// Active lyric word highlight (warm green).
  static const Color highlight = Color(0xFF2E7D32);

  /// Default lyric body color (near-black).
  static const Color lyricText = Color(0xFF1A1A1A);

  /// Text-block wash: white at 10% opacity.
  static const Color textBlockWash = Color(0x1AFFFFFF);

  /// Letterbox / scaffold behind fitted artwork.
  static const Color letterbox = Colors.black;
}

/// Builds the app-wide ThemeData (Nunito + black scaffold).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.letterbox,
      fontFamily: 'Nunito',
      // Rounded system sans if Nunito glyphs are missing during early slice.
      fontFamilyFallback: const [
        'SF Pro Rounded',
        'Hiragino Maru Gothic ProN',
        'sans-serif-rounded',
        'sans-serif',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.highlight,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Nunito',
          color: AppColors.lyricText,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Nunito',
          color: AppColors.lyricText,
          height: 1.35,
        ),
      ),
    );
  }

  /// Phone 18–22 / tablet 24–28 when shortestSide >= 600 (DESIGN §3.7).
  static double lyricFontSize(double shortestSide) {
    if (shortestSide >= 600) {
      return 26;
    }
    return 20;
  }
}
