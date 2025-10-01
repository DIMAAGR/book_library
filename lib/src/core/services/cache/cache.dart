abstract class Cache<K, V> {
  V? get(K key);
  void set(K key, V value);
}
