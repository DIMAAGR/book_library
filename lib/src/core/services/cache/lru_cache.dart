import 'package:book_library/src/core/services/cache/cache.dart';

// Explicação Sobre o que é um LRU Cache em português
// durante o desenvolvimento desse software eu quis deixar mais rico a apresentação dos livros
// e para isso precisei buscar informações em uma API externa, mas como essas informações
// porém vários livros significa várias requisições, e várias requisições significa
// mais tempo de espera para o usuário, e mais custo para o servidor que hospeda a API.
// Para mitigar esse problema eu precisei pesquisar e estudar algumas técnicas de otimização
// e uma delas foi o LRU Cache, que é uma técnica de cache que armazena os dados mais
// recentemente usados, e descarta os dados menos usados quando o cache atinge sua capacidade máxima.
// LRU significa "Least Recently Used", ou "Menos Recentemente Usado" em português.
// A ideia é simples: quando um dado é acessado, ele é movido para o topo da lista de dados mais
// recentemente usados. Quando o cache atinge sua capacidade máxima, o dado que está no
// final da lista (o menos recentemente usado) é removido para dar lugar ao novo dado.
// Isso garante que os dados mais relevantes e frequentemente acessados estejam sempre disponíveis
// no cache, melhorando a performance do sistema como um todo.
//
// Assim eu não precisaria fazer tantas requisições para a API externa, melhorando a experiência do usuário
// e reduzindo o custo para o servidor que hospeda a API.

class LruCache<K, V> implements Cache<K, V> {
  LruCache(this.capacity);
  final int capacity;
  final _map = <K, V>{};

  @override
  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    final v = _map.remove(key) as V;
    _map[key] = v;
    return v;
  }

  @override
  void set(K key, V value) {
    if (_map.containsKey(key)) _map.remove(key);
    _map[key] = value;
    if (_map.length > capacity) _map.remove(_map.keys.first);
  }

  int get length => _map.length;
  Iterable<K> get keys => _map.keys;
}
