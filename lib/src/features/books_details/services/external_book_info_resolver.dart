import 'package:book_library/src/core/services/cache/cache.dart';
import 'package:book_library/src/core/services/coalescing/inflight_coalescer.dart';
import 'package:book_library/src/core/services/concurrency/concurrency_limiter.dart';
import 'package:book_library/src/core/services/key/canonical_key_strategy.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_book_details_use_case.dart';

class ExternalBookInfoResolver {
  ExternalBookInfoResolver({
    required this.usecase,
    required this.cache,
    required this.limiter,
    required this.coalescer,
    required this.keyOf,
  });

  final GetBookDetailsUseCase usecase;
  final Cache<String, ExternalBookInfoEntity?> cache;
  final ConcurrencyLimiter limiter;
  final InflightCoalescer<String, ExternalBookInfoEntity?> coalescer;
  final CanonicalKeyStrategy keyOf;

  Future<ExternalBookInfoEntity?> resolve(String title, String author) async {
    final key = keyOf(title, author);
    final cached = cache.get(key);
    if (cached != null) return cached;

    return coalescer.run(key, () async {
      await limiter.acquire();
      try {
        final either = await usecase(title: title, author: author);
        final entity = either.fold((_) => null, (e) => e);
        if (entity != null) cache.set(key, entity);
        return entity;
      } finally {
        limiter.release();
      }
    });
  }

  Future<void> prefetch(Iterable<({String title, String author})> pairs) async {
    for (final p in pairs) {
      final key = keyOf(p.title, p.author);
      if (cache.get(key) != null) continue;

      coalescer.run(key, () async {
        await limiter.acquire();
        try {
          final either = await usecase(title: p.title, author: p.author);
          final entity = either.fold((_) => null, (e) => e);
          if (entity != null) cache.set(key, entity);
          return entity;
        } finally {
          limiter.release();
        }
      });
    }
  }
}
