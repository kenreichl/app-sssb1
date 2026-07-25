// Bootstrap: bindings, system chrome, then run the book app.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

Future<void> main() async {
  // Required before any plugin / SystemChrome calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Hide status / nav chrome for immersive reading UI (DESIGN §1.2).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Start portrait; BookShell locks per page (cover/back portrait, spreads landscape).
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  runApp(const SunnySideSongsApp());
}
