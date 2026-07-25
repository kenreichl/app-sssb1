// Root MaterialApp: theme + home shell.
import 'package:flutter/material.dart';

import 'ui/screens/book_shell.dart';
import 'ui/theme/app_theme.dart';

/// Top-level app widget for Sunny Side Songs v1.
class SunnySideSongsApp extends StatelessWidget {
  const SunnySideSongsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunny Side Songs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // BookShell owns navigation across the 8 screens.
      home: const BookShell(),
    );
  }
}
