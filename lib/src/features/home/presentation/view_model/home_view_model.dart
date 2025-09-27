import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_view_model_state.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel {
  HomeViewModel(this._getBooks, this._getCategories, this._resolver);
  final GetAllBooksUseCase _getBooks;
  final GetCategoriesUseCase _getCategories;

  final ExternalBookInfoResolver _resolver;

  final ValueNotifier<ViewModelState<Failure, HomeData>> state =
      ValueNotifier<ViewModelState<Failure, HomeData>>(InitialState());

  final ValueNotifier<UiEvent?> event = ValueNotifier<UiEvent?>(null);

  final ValueNotifier<Map<String, ExternalBookInfoEntity>> byBookId = ValueNotifier(
    <String, ExternalBookInfoEntity>{},
  );

  Future<void> load() async {
    state.value = LoadingState();

    final catsEither = await _getCategories();
    return catsEither.fold(
      (f) {
        state.value = ErrorState(f);
        event.value = ShowErrorSnackBar(f.message);
      },
      (cats) async {
        final booksEither = await _getBooks();
        booksEither.fold(
          (f) {
            state.value = ErrorState(f);
            event.value = ShowErrorSnackBar(f.message);
          },
          (books) {
            final mid = (books.length / 2).floor();
            final data = HomeData(
              categories: cats,
              activeCategoryId: cats.isNotEmpty ? cats.first.id : null,
              library: books.take(mid).toList(),
              explore: books.skip(mid).toList(),
            );
            state.value = SuccessState(data);

            _prefetchFor(data.library.take(6));
            _prefetchFor(data.explore.take(6));
          },
        );
      },
    );
  }

  void selectCategory(String id) {
    final current = state.value;
    if (current is SuccessState<Failure, HomeData>) {
      if (current.success.activeCategoryId == id) return;
      final updated = current.success.copyWith(activeCategoryId: id);
      state.value = SuccessState(updated);

      _prefetchFor(updated.library.take(6));
    }
  }

  Future<void> resolveFor(BookEntity book) async {
    if (byBookId.value.containsKey(book.id)) return;

    final info = await _resolver.resolve(book.title, book.author);
    if (info != null) {
      final next = Map<String, ExternalBookInfoEntity>.from(byBookId.value);
      next[book.id] = info;
      byBookId.value = next;
    }
  }

  Future<void> _prefetchFor(Iterable<BookEntity> books) async {
    final pairs = books.map((b) => (title: b.title, author: b.author));
    await _resolver.prefetch(pairs);
  }

  void consumeEvent() => event.value = null;
}
