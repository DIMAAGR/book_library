import 'dart:async';

import 'package:book_library/src/core/services/coalescing/inflight_coalescer.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  group('MapInflightCoalescer', () {
    test('coalesces chamadas simultâneas com a mesma chave', () async {
      final c = MapInflightCoalescer<String, int>();
      final completer = Completer<int>();
      var calls = 0;

      Future<int> task() async {
        calls++;
        return completer.future;
      }

      final f1 = c.run('k', task);
      final f2 = c.run('k', task);

      expect(calls, 1);

      completer.complete(42);

      final r1 = await f1;
      final r2 = await f2;

      expect(r1, 42);
      expect(r2, 42);
      expect(calls, 1);
    });

    test('depois que completa, nova chamada dispara novo task', () async {
      final c = MapInflightCoalescer<String, int>();

      var calls = 0;
      Future<int> taskOnce(int value) async {
        calls++;
        return value;
      }

      final r1 = await c.run('k', () => taskOnce(1));
      expect(r1, 1);
      expect(calls, 1);

      final r2 = await c.run('k', () => taskOnce(2));
      expect(r2, 2);
      expect(calls, 2);
    });

    test('propaga erro para todos os aguardando e limpa inflight', () async {
      final c = MapInflightCoalescer<String, int>();
      final completer = Completer<int>();
      var calls = 0;

      Future<int> task() async {
        calls++;
        return completer.future;
      }

      final f1 = c.run('k', task);
      final f2 = c.run('k', task);
      expect(calls, 1);

      completer.completeError(StateError('boom'));

      await expectLater(f1, throwsA(isA<StateError>()));
      await expectLater(f2, throwsA(isA<StateError>()));

      final r3 = await c.run('k', () async => 5);
      expect(r3, 5);
    });
  });
}
