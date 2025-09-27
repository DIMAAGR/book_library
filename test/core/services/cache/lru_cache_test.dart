import 'package:book_library/src/core/services/cache/lru_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('get move o item para mais recente', () {
    final cache = LruCache<String, int>(2);
    cache.set('a', 1);
    cache.set('b', 2);

    expect(cache.keys.toList(), ['a', 'b']);

    expect(cache.get('a'), 1);
    expect(cache.keys.toList(), ['b', 'a']);
  });

  test('estoura capacidade remove o menos recente', () {
    final cache = LruCache<String, int>(2);
    cache.set('a', 1);
    cache.set('b', 2);

    cache.set('c', 3);
    expect(cache.keys.toList(), ['b', 'c']);
    expect(cache.get('a'), isNull);
  });

  test('overwrite atualiza e move para mais recente', () {
    final cache = LruCache<String, int>(2);
    cache.set('a', 1);
    cache.set('b', 2);
    cache.set('a', 42);
    expect(cache.get('a'), 42);
    expect(cache.keys.last, 'a');
  });
}
