import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/library/presentation/view_model/library_state_object.dart';
import 'package:flutter/foundation.dart';

class LibraryViewModel {
  LibraryViewModel(this._getBooks, this._getCategories, this._resolver);

  final GetAllBooksUseCase _getBooks;
  final GetCategoriesUseCase _getCategories;
  final ExternalBookInfoResolver _resolver;

  // Eu nem falei isso na vm do home, mas vi esse padrão do LibraryDataObject em mais projetos.
  // pesquisei sobre e descobri que esse padrão do LibraryDataObject (que obviamente é um ValueObject)
  // é a base para diversos gerenciadores de estado, como o BLoC.
  // Juntar tudo em um único objeto facilita o gerenciamento do estado.
  // O Equatable ajuda a comparar instâncias e otimizar atualizações de UI.
  // Acho que vale a pena manter esse padrão... pelo menos nesse projeto.
  final ValueNotifier<LibraryStateObject> state = ValueNotifier<LibraryStateObject>(
    LibraryStateObject.initial(),
  );

  final ValueNotifier<UiEvent?> event = ValueNotifier<UiEvent?>(null);

  Future<void> load() async {
    state.value = state.value.copyWith(state: LoadingState());

    final catsEither = await _getCategories();
    await catsEither.fold(
      (f) {
        state.value = state.value.copyWith(state: ErrorState(f));
        event.value = ShowErrorSnackBar(f.message);
      },
      (cats) async {
        final booksEither = await _getBooks();
        booksEither.fold(
          (f) {
            state.value = state.value.copyWith(state: ErrorState(f));
            event.value = ShowErrorSnackBar(f.message);
          },
          (books) {
            final payload = LibraryPayload(
              categories: cats,
              items: books,
              activeCategoryId: cats.isNotEmpty ? cats.first.id : null,
            );

            state.value = state.value.copyWith(state: SuccessState(payload));

            _prefetchFor(books.take(8));
          },
        );
      },
    );
  }

  void selectCategory(String id) {
    final current = state.value.state;
    if (current is! SuccessState<Failure, LibraryPayload>) return;

    final payload = current.success;
    if (payload.activeCategoryId == id) return;

    final updatedPayload = payload.copyWith(activeCategoryId: id);
    state.value = state.value.copyWith(state: SuccessState(updatedPayload));

    _prefetchFor(updatedPayload.items.take(8));
  }

  Future<void> resolveFor(BookEntity book) async {
    if (state.value.byBookId.containsKey(book.id)) return;

    final info = await _resolver.resolve(book.title, book.author);
    if (info == null) return;

    final nextMap = Map<String, ExternalBookInfoEntity>.from(state.value.byBookId)
      ..[book.id] = info;

    state.value = state.value.copyWith(byBookId: nextMap);
  }

  Future<void> _prefetchFor(Iterable<BookEntity> books) async {
    final pairs = books.map((b) => (title: b.title, author: b.author));
    await _resolver.prefetch(pairs);
  }

  void consumeEvent() => event.value = null;
}
