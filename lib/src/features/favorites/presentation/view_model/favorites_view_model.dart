import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/core/viewmodel/cover_prefetch_mixin.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/favorites/presentation/view_model/favorites_state_object.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:flutter/foundation.dart';

class FavoritesViewModel extends BaseViewModel with CoverPrefetchMixin {
  FavoritesViewModel(
    this.getAllBooks,
    this.getFavoritesIds,
    this.toggleFavorite,
    this.infoResolver,
  );

  final GetAllBooksUseCase getAllBooks;
  final GetFavoritesIdsUseCase getFavoritesIds;
  final ToggleFavoriteUseCase toggleFavorite;
  final ExternalBookInfoResolver infoResolver;

  final ValueNotifier<FavoritesStateObject> state = ValueNotifier(FavoritesStateObject.initial());

  Future<void> init() async {
    state.value = state.value.copyWith(state: LoadingState());
    final favs = await getFavoritesIds();
    await favs.fold(
      (f) {
        state.value = state.value.copyWith(state: ErrorState(f));
        emit(ShowErrorSnackBar(f.message));
      },
      (ids) async {
        state.value = state.value.copyWith(favorites: ids);
        await _loadAllAndCompose();
      },
    );
  }

  Future<void> _loadAllAndCompose() async {
    final res = await getAllBooks();
    await res.fold(
      (f) {
        state.value = state.value.copyWith(state: ErrorState(f));
        emit(ShowErrorSnackBar(f.message));
      },
      (all) async {
        final favIds = state.value.favorites;
        final onlyFavs = all.where((b) => favIds.contains(b.id)).toList();
        final sorted = state.value.sort.sort(onlyFavs);

        state.value = state.value.copyWith(
          state: SuccessState<Failure, List<BookEntity>>(all),
          items: sorted,
        );

        await prefetchMissingCovers(sorted.take(16));
      },
    );
  }

  Future<void> onToggleFavorite(String id) async {
    final res = await toggleFavorite(id);
    res.fold((f) => emit(ShowErrorSnackBar(f.message)), (updatedIds) {
      final currentAll = state.value.state.successOrNull ?? <BookEntity>[];
      final nextItems = currentAll.where((b) => updatedIds.contains(b.id)).toList();
      final sorted = state.value.sort.sort(nextItems);
      state.value = state.value.copyWith(favorites: updatedIds, items: sorted);
    });
  }

  void changeSort(SortStrategy s) {
    if (state.value.sort.runtimeType == s.runtimeType) return;
    final sorted = s.sort([...state.value.items]);
    state.value = state.value.copyWith(sort: s, items: sorted);
  }

  bool hasInfoFor(String id) => state.value.byBookId.containsKey(id);

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  ExternalBookInfoResolver get coverResolver => infoResolver;

  @override
  Map<String, ExternalBookInfoEntity> readByBookId() => state.value.byBookId;

  @override
  void writeByBookId(Map<String, ExternalBookInfoEntity> next) {
    state.value = state.value.copyWith(byBookId: next);
  }
}
