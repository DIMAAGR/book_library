import 'dart:async';
import 'dart:collection';

import 'package:book_library/src/core/services/concurrency/concurrency_limiter.dart';

class SemaphoreLimiter implements ConcurrencyLimiter {
  SemaphoreLimiter(this._max);

  int _current = 0;
  final int _max;
  final Queue<Completer<void>> _q = Queue();

  @override
  Future<void> acquire() async {
    if (_current < _max) {
      _current++;
      return;
    }
    final c = Completer<void>();
    _q.add(c);
    await c.future;
  }

  @override
  void release() {
    if (_q.isNotEmpty) {
      _q.removeFirst().complete();
    } else {
      _current = (_current - 1).clamp(0, _max);
    }
  }
}
