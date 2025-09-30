import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';

mixin CoverPrefetchMixin on BaseViewModel {
  ExternalBookInfoResolver get coverResolver;

  Map<String, ExternalBookInfoEntity> readByBookId();
  void writeByBookId(Map<String, ExternalBookInfoEntity> next);

  Future<void> prefetchFor(Iterable<BookEntity> books, {int? limit}) async {
    if (isDisposed) return;

    final selected = (limit == null) ? books : books.take(limit);
    final pairs = selected.map((b) => (title: b.title, author: b.author));
    await coverResolver.prefetch(pairs);
  }

  Future<void> resolveCoverIfMissing(BookEntity book) async {
    if (isDisposed || readByBookId().containsKey(book.id)) return;

    final info = await coverResolver.resolve(book.title, book.author);
    if (isDisposed || info == null) return;

    final next = Map<String, ExternalBookInfoEntity>.from(readByBookId())..[book.id] = info;
    writeByBookId(next);
  }

  Future<void> prefetchMissingCovers(Iterable<BookEntity> books, {int? limit}) async {
    try {
      if (isDisposed) return;

      final byId = readByBookId();
      final toFetch = <BookEntity>[];

      for (final b in books) {
        if (!byId.containsKey(b.id)) {
          toFetch.add(b);
          if (limit != null && toFetch.length >= limit) break;
        }
      }
      if (toFetch.isEmpty) return;

      for (final b in toFetch) {
        if (isDisposed) return;

        final info = await coverResolver.resolve(b.title, b.author);
        if (isDisposed || info == null) continue;

        final cur = readByBookId();
        final next = Map<String, ExternalBookInfoEntity>.from(cur)..[b.id] = info;
        writeByBookId(next);
      }
    } catch (_) {
      emit(ShowSnackBar('Failed to prefetch covers'));
    }
  }
}
