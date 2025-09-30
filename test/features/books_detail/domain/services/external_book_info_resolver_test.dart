import 'dart:async';

import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/services/cache/lru_cache.dart';
import 'package:book_library/src/core/services/coalescing/inflight_coalescer.dart';
import 'package:book_library/src/core/services/key/default_canonical_key.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

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
  late MockGetBookDetailsUseCase mockUsecase;
  late MockCache<String, ExternalBookInfoEntity?> mockCache;
  late MockConcurrencyLimiter mockLimiter;
  late InflightCoalescer<String, ExternalBookInfoEntity?> coalescer;
  late ExternalBookInfoResolver resolver;

  setUp(() {
    mockUsecase = MockGetBookDetailsUseCase();
    mockCache = MockCache<String, ExternalBookInfoEntity?>();
    mockLimiter = MockConcurrencyLimiter();
    coalescer = MapInflightCoalescer<String, ExternalBookInfoEntity?>();

    resolver = ExternalBookInfoResolver(
      usecase: mockUsecase,
      cache: mockCache,
      limiter: mockLimiter,
      coalescer: coalescer,
      keyOf: DefaultCanonicalKey(),
    );
  });

  test('prefetch: ignora itens já em cache e grava os não-cacheados', () async {
    when(mockCache.get('b1|a1')).thenReturn(const ExternalBookInfoEntity(title: 'x'));
    when(mockCache.get('b2|a2')).thenReturn(null);

    when(mockLimiter.acquire()).thenAnswer((_) async {});
    when(mockLimiter.release()).thenReturn(null);

    when(
      mockUsecase(title: 'B2', author: 'A2'),
    ).thenAnswer((_) async => const Right(ExternalBookInfoEntity(title: 'b2')));

    await resolver.prefetch([(title: 'B1', author: 'A1'), (title: 'B2', author: 'A2')]);

    await untilCalled(mockCache.set('b2|a2', any as ExternalBookInfoEntity?));

    verify(mockUsecase(title: 'B2', author: 'A2')).called(1);
    verifyNever(mockUsecase(title: 'B1', author: 'A1'));
    verify(mockCache.set('b2|a2', const ExternalBookInfoEntity(title: 'b2'))).called(1);
  });
  test('resolve coalesce + cache write', () async {
    final cache = LruCache<String, ExternalBookInfoEntity?>(64);

    resolver = ExternalBookInfoResolver(
      usecase: mockUsecase,
      cache: cache,
      limiter: mockLimiter,
      coalescer: MapInflightCoalescer<String, ExternalBookInfoEntity?>(),
      keyOf: DefaultCanonicalKey(),
    );

    when(mockLimiter.acquire()).thenAnswer((_) async {});
    when(mockLimiter.release()).thenReturn(null);

    final completer = Completer<Either<Failure, ExternalBookInfoEntity?>>();
    when(mockUsecase(title: 'T', author: 'A')).thenAnswer((_) => completer.future);

    final f1 = resolver.resolve('T', 'A');
    final f2 = resolver.resolve('T', 'A');

    await untilCalled(mockUsecase(title: 'T', author: 'A'));
    verify(mockUsecase(title: 'T', author: 'A')).called(1);

    completer.complete(const Right(ExternalBookInfoEntity(title: 'ok')));
    final r1 = await f1;
    final r2 = await f2;

    expect(r1?.title, 'ok');
    expect(r2?.title, 'ok');
    expect(cache.get('t|a')?.title, 'ok');

    verify(mockLimiter.acquire()).called(1);
    verify(mockLimiter.release()).called(1);
    verifyNoMoreInteractions(mockUsecase);
  });
}
