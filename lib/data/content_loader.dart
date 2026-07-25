// Load and parse spread / back-cover markdown + timecode JSON from assets.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../models/back_cover_content.dart';
import '../models/book_page.dart';
import '../models/text_block_rect.dart';
import '../models/timecode_track.dart';
import 'book_catalog.dart';

/// Loads book content from rootBundle (offline assets only).
class ContentLoader {
  ContentLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Loads the full ordered book (cover → spreads 1–6 → back).
  Future<List<BookPage>> loadBook() async {
    final pages = <BookPage>[
      CoverPage(
        index: BookCatalog.coverIndex,
        imageAsset: BookCatalog.coverFrontImage,
        audioAsset: BookCatalog.coverFrontAudio,
      ),
    ];

    for (var n = 1; n <= 6; n++) {
      pages.add(await loadSpread(n));
    }

    pages.add(await loadBackCover());
    return pages;
  }

  /// Parse one spread markdown + matching timecode JSON.
  Future<SpreadPage> loadSpread(int n) async {
    final md = await _bundle.loadString(BookCatalog.spreadMarkdown(n));
    final parsed = _parseFrontmatter(md);
    final fm = parsed.frontmatter;
    final bodyLines = parsed.body.split('\n');

    // Non-blank lines map to l1…; blank lines are stanza spacing only.
    final lyricLines = <String?>[];
    for (final raw in bodyLines) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        // Preserve stanza gaps as null placeholders for layout spacing.
        if (lyricLines.isNotEmpty && lyricLines.last != null) {
          lyricLines.add(null);
        }
      } else {
        lyricLines.add(line.trim());
      }
    }
    // Drop trailing spacer.
    while (lyricLines.isNotEmpty && lyricLines.last == null) {
      lyricLines.removeLast();
    }

    final illustration = fm['illustration'] as String? ?? 'artwork_spread$n.png';
    final audioFile = fm['audio'] as String? ?? '0$n.mp3';
    final title = fm['title'] as String? ?? 'spread $n';
    final textBlock =
        TextBlockRect.fromYamlMap(Map<dynamic, dynamic>.from(fm['text_block'] as Map));

    final timecodeRaw =
        await _bundle.loadString(BookCatalog.spreadTimecode(n));
    final timecodeJson =
        jsonDecode(timecodeRaw) as Map<String, dynamic>;
    final timecode = TimecodeTrack.fromJson(timecodeJson);

    return SpreadPage(
      index: n, // cover=0, spreads 1–6, back=7
      spreadNumber: n,
      title: title,
      imageAsset: BookCatalog.imagePath(illustration),
      audioAsset: BookCatalog.audioPath(audioFile),
      textBlock: textBlock,
      lyricLines: lyricLines,
      timecode: timecode,
    );
  }

  /// Parse back-cover markdown with ## author_bio / illustrator_bio / book_info.
  Future<BackCoverPage> loadBackCover() async {
    final md = await _bundle.loadString(BookCatalog.coverBackMarkdown);
    final parsed = _parseFrontmatter(md);
    final fm = parsed.frontmatter;
    final sections = _parseSections(parsed.body);

    final illustration =
        fm['illustration'] as String? ?? 'artwork_cover_back.jpg';
    final audioFile = fm['audio'] as String? ?? '07_cover_back_twinkle.mp3';
    final logo = fm['logo'] as String? ?? 'logo_cover_back.png';
    final authorPhoto = fm['author_photo'] as String? ?? 'photo-bio-ng.jpg';
    final illustratorPhoto =
        fm['illustrator_photo'] as String? ?? 'photo-bio-nt.jpg';
    final textBlock =
        TextBlockRect.fromYamlMap(Map<dynamic, dynamic>.from(fm['text_block'] as Map));

    final content = BackCoverContent(
      illustration: illustration,
      audio: audioFile,
      logo: logo,
      authorPhoto: authorPhoto,
      illustratorPhoto: illustratorPhoto,
      textBlock: textBlock,
      authorBio: sections['author_bio'] ?? '',
      illustratorBio: sections['illustrator_bio'] ?? '',
      bookInfo: sections['book_info'] ?? '',
    );

    return BackCoverPage(
      index: BookCatalog.backCoverIndex,
      imageAsset: BookCatalog.imagePath(illustration),
      audioAsset: BookCatalog.audioPath(audioFile),
      content: content,
    );
  }

  /// Splits `---` YAML frontmatter from markdown body.
  _MdParts _parseFrontmatter(String raw) {
    final trimmed = raw.trimLeft();
    if (!trimmed.startsWith('---')) {
      return _MdParts(frontmatter: const {}, body: raw);
    }
    final end = trimmed.indexOf('\n---', 3);
    if (end < 0) {
      return _MdParts(frontmatter: const {}, body: raw);
    }
    final yamlBlock = trimmed.substring(3, end).trim();
    final body = trimmed.substring(end + 4).trim();
    final yamlMap = loadYaml(yamlBlock);
    final map = yamlMap is YamlMap
        ? Map<dynamic, dynamic>.from(yamlMap)
        : <dynamic, dynamic>{};
    return _MdParts(frontmatter: map, body: body);
  }

  /// Extracts `## heading` sections from back-cover body.
  Map<String, String> _parseSections(String body) {
    final result = <String, String>{};
    final lines = body.split('\n');
    String? current;
    final buffer = StringBuffer();

    void flush() {
      if (current != null) {
        result[current] = buffer.toString().trim();
        buffer.clear();
      }
    }

    for (final line in lines) {
      if (line.startsWith('## ')) {
        flush();
        current = line.substring(3).trim();
      } else if (current != null) {
        buffer.writeln(line);
      }
    }
    flush();
    return result;
  }
}

class _MdParts {
  const _MdParts({required this.frontmatter, required this.body});
  final Map<dynamic, dynamic> frontmatter;
  final String body;
}
