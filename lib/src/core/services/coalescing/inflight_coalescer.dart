abstract class InflightCoalescer<K, V> {
  Future<V> run(K key, Future<V> Function() task);
}
