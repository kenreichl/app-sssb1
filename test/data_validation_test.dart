// Automated data checks: spreads 1–6 + back cover assets/frontmatter.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final root = Directory.current.path;
  final dataDir = Directory('$root/assets/data');
  final imagesDir = Directory('$root/assets/images');
  final audioDir = Directory('$root/assets/audio');

  bool fileExists(Directory dir, String name) =>
      File('${dir.path}/$name').existsSync();

  group('Spread data validation', () {
    for (var n = 1; n <= 6; n++) {
      test('spread $n markdown + timecode + assets', () {
        final mdFile = File('${dataDir.path}/text_spread$n.md');
        final jsonFile = File('${dataDir.path}/timecode_spread$n.json');
        expect(mdFile.existsSync(), isTrue, reason: 'missing text_spread$n.md');
        expect(jsonFile.existsSync(), isTrue,
            reason: 'missing timecode_spread$n.json');

        final md = mdFile.readAsStringSync();
        expect(md.trimLeft().startsWith('---'), isTrue);

        final end = md.trimLeft().indexOf('\n---', 3);
        expect(end, greaterThan(0));
        final yamlBlock = md.trimLeft().substring(3, end).trim();
        final body = md.trimLeft().substring(end + 4);
        final fm = loadYaml(yamlBlock) as YamlMap;

        expect(fm.containsKey('text_block'), isTrue);
        final tb = fm['text_block'] as YamlMap;
        for (final key in ['x', 'y', 'width', 'height']) {
          final v = (tb[key] as num).toDouble();
          expect(v >= 0 && v <= 1, isTrue, reason: 'text_block.$key out of range');
        }
        final x = (tb['x'] as num).toDouble();
        final y = (tb['y'] as num).toDouble();
        final w = (tb['width'] as num).toDouble();
        final h = (tb['height'] as num).toDouble();
        expect(x + w <= 1.0001, isTrue);
        expect(y + h <= 1.0001, isTrue);

        final illustration = fm['illustration'] as String;
        final audio = fm['audio'] as String;
        expect(fileExists(imagesDir, illustration), isTrue,
            reason: 'missing image $illustration');
        expect(fileExists(audioDir, audio), isTrue,
            reason: 'missing audio $audio');

        // Non-blank lyric lines → expected l1…lN.
        final nonBlank = body
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        final expectedIds = {
          for (var i = 1; i <= nonBlank.length; i++) 'l$i',
        };

        final json =
            jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
        expect(json.containsKey('lines'), isTrue);
        final lines = (json['lines'] as List).cast<Map<String, dynamic>>();
        final ids = lines.map((l) => l['id'] as String).toSet();

        for (final id in ids) {
          expect(expectedIds.contains(id), isTrue,
              reason: 'timecode id $id has no lyric line');
        }
        final unused = expectedIds.difference(ids);
        // Unused lyric lines are a warning-level content issue; still assert empty
        // so content stays in sync (fix assets if this fails).
        expect(unused, isEmpty,
            reason: 'lyric lines without timecode: $unused');
      });
    }
  });

  group('Back cover data validation', () {
    test('sections and assets exist', () {
      final mdFile = File('${dataDir.path}/text_cover_back.md');
      expect(mdFile.existsSync(), isTrue);
      final md = mdFile.readAsStringSync();

      expect(md.contains('## author_bio'), isTrue);
      expect(md.contains('## illustrator_bio'), isTrue);
      expect(md.contains('## book_info'), isTrue);

      final end = md.trimLeft().indexOf('\n---', 3);
      final yamlBlock = md.trimLeft().substring(3, end).trim();
      final fm = loadYaml(yamlBlock) as YamlMap;

      for (final key in [
        'illustration',
        'audio',
        'logo',
        'author_photo',
        'illustrator_photo',
      ]) {
        expect(fm.containsKey(key), isTrue, reason: 'missing frontmatter $key');
      }

      expect(fileExists(imagesDir, fm['illustration'] as String), isTrue);
      expect(fileExists(audioDir, fm['audio'] as String), isTrue);
      expect(fileExists(imagesDir, fm['logo'] as String), isTrue);
      expect(fileExists(imagesDir, fm['author_photo'] as String), isTrue);
      expect(fileExists(imagesDir, fm['illustrator_photo'] as String), isTrue);

      final tb = fm['text_block'] as YamlMap;
      final x = (tb['x'] as num).toDouble();
      final y = (tb['y'] as num).toDouble();
      final w = (tb['width'] as num).toDouble();
      final h = (tb['height'] as num).toDouble();
      expect(x >= 0 && y >= 0 && w > 0 && h > 0, isTrue);
      expect(x + w <= 1.0001 && y + h <= 1.0001, isTrue);
    });
  });
}
