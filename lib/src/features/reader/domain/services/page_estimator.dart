import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';

abstract class PageEstimator {
  int estimateTotalPages({
    required int paragraphCount,
    required double fontSize,
    required ReaderLineHeight lineHeight,
  });
}

class DensityPageEstimator implements PageEstimator {
  const DensityPageEstimator();

  @override
  int estimateTotalPages({
    required int paragraphCount,
    required double fontSize,
    required ReaderLineHeight lineHeight,
  }) {
    const baseFont = 16.0;
    const baseLines = 1.5;
    const basePerPage = 24;

    final fontFactor = fontSize / baseFont;

    final lineFactor = switch (lineHeight) {
      ReaderLineHeight.compact => 1.25 / baseLines,
      ReaderLineHeight.comfortable => 1.5 / baseLines,
      ReaderLineHeight.spacious => 1.75 / baseLines,
    };

    final effectivePerPage = basePerPage / (fontFactor * lineFactor);

    return (paragraphCount / effectivePerPage).ceil().clamp(1, 999);
  }
}
