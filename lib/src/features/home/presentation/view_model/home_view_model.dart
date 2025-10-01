import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/core/viewmodel/cover_prefetch_mixin.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_state_object.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends BaseViewModel with CoverPrefetchMixin {
  HomeViewModel(this._getBooks, this._getCategories, this._resolver);

  final GetAllBooksUseCase _getBooks;
  final GetCategoriesUseCase _getCategories;
  final ExternalBookInfoResolver _resolver;

  final ValueNotifier<HomeStateObject> state = ValueNotifier(HomeStateObject.initial());

  Future<void> load() async {
    state.value = state.value.copyWith(state: LoadingState<Failure, HomePayload>());

    final cats = await _getCategories();
    await cats.fold(
      (f) {
        state.value = state.value.copyWith(state: ErrorState<Failure, HomePayload>(f));
        emit(ShowErrorSnackBar(f.message));
      },
      (c) async {
        final books = await _getBooks();
        books.fold(
          (f) {
            state.value = state.value.copyWith(state: ErrorState<Failure, HomePayload>(f));
            emit(ShowErrorSnackBar(f.message));
          },
          (list) {
            final mid = (list.length / 2).floor();
            final library = list.take(mid).toList();
            final explore = list.skip(mid).toList();

            final payload = HomePayload(
              categories: c,
              activeCategoryId: c.isNotEmpty ? c.first.id : null,
              library: library,
              explore: explore,
            );

            state.value = state.value.copyWith(
              state: SuccessState<Failure, HomePayload>(payload),
              categories: c,
              activeCategoryId: payload.activeCategoryId,
              library: library,
              explore: explore,
            );

            final libSlice = library.take(6);
            final expSlice = explore.take(6);

            prefetchFor(libSlice);
            prefetchMissingCovers(libSlice);

            prefetchFor(expSlice);
            prefetchMissingCovers(expSlice);
          },
        );
      },
    );
  }

  void selectCategory(String id) {
    final s = state.value.state;
    if (s is! SuccessState<Failure, HomePayload>) return;
    if (state.value.activeCategoryId == id) return;

    final nextPayload = s.success.copyWith(activeCategoryId: id);
    state.value = state.value.copyWith(
      state: SuccessState<Failure, HomePayload>(nextPayload),
      activeCategoryId: id,
    );

    final slice = state.value.library.take(6);
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
