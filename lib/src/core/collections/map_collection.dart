Map<K, V> copyWithEntry<K, V>(Map<K, V> source, K key, V value) {
  final next = Map<K, V>.from(source);
  next[key] = value;
  return next;
}
