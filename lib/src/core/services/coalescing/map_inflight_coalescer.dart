import 'package:book_library/src/core/services/coalescing/inflight_coalescer.dart';

class MapInflightCoalescer<K, V> implements InflightCoalescer<K, V> {
  final _inflight = <K, Future<V>>{};
  @override
  Future<V> run(K key, Future<V> Function() task) {
    final existing = _inflight[key];
    if (existing != null) return existing;
    final future = task();
    _inflight[key] = future;
    return future.whenComplete(() => _inflight.remove(key));
  }
}
