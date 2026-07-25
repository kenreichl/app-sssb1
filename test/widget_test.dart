// Smoke test: app builds and shows a loading or book scaffold.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_sssb1/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SunnySideSongsApp builds', (tester) async {
    SharedPreferences.setMockInitialValues({});
    // Avoid SystemChrome / orientation / audio plugin side effects hanging tests:
    // pump the MaterialApp shell briefly.
    await tester.pumpWidget(const SunnySideSongsApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    // Either loading spinner or book scaffold.
    expect(
      find.byType(Scaffold),
      findsWidgets,
    );
  });
}
