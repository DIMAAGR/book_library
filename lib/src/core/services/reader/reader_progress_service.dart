import 'dart:async';

import 'package:book_library/src/core/types/progress_saver.dart';

abstract class ReaderProgressService {
  (int page, int percent) compute(int totalPages, double scrollRatio, int currentPercent);
  Future<void> saveDebounced(String bookId, int percent);
  void dispose();
}

class DebouncedReaderProgressService implements ReaderProgressService {
  DebouncedReaderProgressService({required this.save, this.debounceMs = 300});

  final ProgressSaver save;
  final int debounceMs;
  Timer? _t;
  int? _lastQueued;
  String? _lastBook;

  @override
  (int page, int percent) compute(int totalPages, double ratio, int currentPercent) {
    final tp = totalPages.clamp(1, 999);
    final page = (ratio * (tp - 1)).round() + 1;
    final percent = tp <= 1 ? 100 : ((page - 1) * (100 / (tp - 1))).round().clamp(0, 100);
    return (page.clamp(1, tp), percent);
  }

  @override
  Future<void> saveDebounced(String bookId, int percent) async {
    _lastBook = bookId;
    _lastQueued = percent;
    _t?.cancel();
    _t = Timer(Duration(milliseconds: debounceMs), () async {
      final b = _lastBook, p = _lastQueued;
      if (b != null && p != null) {
        await save(b, p);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
  }
}
