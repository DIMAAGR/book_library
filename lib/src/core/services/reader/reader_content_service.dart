import 'package:book_library/src/core/models/reader_paragraph.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/services.dart';

abstract class ReaderContentService {
  Future<List<ReaderParagraph>> loadFromAsset(String assetPath);
}

class EpubReaderContentService implements ReaderContentService {
  const EpubReaderContentService();

  @override
  Future<List<ReaderParagraph>> loadFromAsset(String assetPath) async {
    final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
    final book = await EpubReader.readBook(bytes);

    final chapters = book.Chapters ?? <EpubChapter>[];
    final out = <ReaderParagraph>[];

    for (final ch in chapters) {
      final title = (ch.Title ?? '').trim();
      final html = (ch.HtmlContent ?? ch.ContentFileName ?? '').toString();
      final plain = _htmlToPlain(html);

      for (final p in plain.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty)) {
        out.add(ReaderParagraph(title: title, text: p));
      }
    }
    return out;
  }

  String _htmlToPlain(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }
}
