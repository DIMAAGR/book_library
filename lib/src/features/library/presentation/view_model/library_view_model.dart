import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/core/viewmodel/cover_prefetch_mixin.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/library/presentation/view_model/library_state_object.dart';
import 'package:flutter/foundation.dart';

class LibraryViewModel extends BaseViewModel with CoverPrefetchMixin {
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
  final ValueNotifier<LibraryStateObject> state = ValueNotifier(LibraryStateObject.initial());

  Future<void> load() async {
    state.value = state.value.copyWith(state: LoadingState());

    final cats = await _getCategories();
    await cats.fold(
      (f) {
        state.value = state.value.copyWith(state: ErrorState(f));
        emit(ShowErrorSnackBar(f.message));
      },
      (c) async {
        final books = await _getBooks();
        books.fold(
          (f) {
            state.value = state.value.copyWith(state: ErrorState(f));
            emit(ShowErrorSnackBar(f.message));
          },
          (list) {
            final payload = LibraryPayload(
              categories: c,
              items: list,
              activeCategoryId: c.isNotEmpty ? c.first.id : null,
            );
            state.value = state.value.copyWith(state: SuccessState(payload));

            final slice = list.take(8);
            prefetchFor(slice);
            prefetchMissingCovers(slice);
          },
        );
      },
    );
  }

  void selectCategory(String id) {
    final s = state.value.state;
    if (s is! SuccessState<Failure, LibraryPayload>) return;

    final payload = s.success;
    if (payload.activeCategoryId == id) return;

    final updated = payload.copyWith(activeCategoryId: id);
    state.value = state.value.copyWith(state: SuccessState(updated));
    final slice = updated.items.take(8);
    prefetchFor(slice);
    prefetchMissingCovers(slice);
  }

  @override
  ExternalBookInfoResolver get coverResolver => _resolver;

  @override
  Map<String, ExternalBookInfoEntity> readByBookId() => state.value.byBookId;

  @override
  void writeByBookId(Map<String, ExternalBookInfoEntity> next) {
    state.value = state.value.copyWith(byBookId: next);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}
