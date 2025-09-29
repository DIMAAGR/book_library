import 'package:book_library/src/core/collections/map_collection.dart';
import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_book_by_title_use_case.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/search/domain/specifications/book_specifications.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:book_library/src/features/search/presentation/debounce/debouncer.dart';
import 'package:book_library/src/features/search/presentation/view_model/search_state_object.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class SearchViewModel extends BaseViewModel {
  SearchViewModel(
    this._getAll,
    this._getByTitle,
    this._getFavs,
    this._toggleFav,
    this._resolver, {
    Debouncer? debouncer,
  }) : _debouncer = debouncer ?? Debouncer();

  final GetAllBooksUseCase _getAll;
  final GetBookByTitleUseCase _getByTitle;
  final GetFavoritesIdsUseCase _getFavs;
  final ToggleFavoriteUseCase _toggleFav;
  final ExternalBookInfoResolver _resolver;

  final Debouncer _debouncer;

  final ValueNotifier<SearchStateObject> state = ValueNotifier<SearchStateObject>(
    SearchStateObject.initial(),
  );

  Future<void> init() async {
    final favs = await _getFavs();
    favs.fold(
      (f) => emit(ShowErrorSnackBar(f.message)),
      (set) => state.value = state.value.copyWith(favorites: set),
    );
    await _searchNow();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    state.dispose();
    super.dispose();
  }

  void onTextChanged(String v) {
    state.value = state.value.copyWith(text: v);
    _debouncer.run(_searchNow);
  }

  void setRange(PublishedRange r) {
    if (state.value.filters.range == r) return;
    state.value = state.value.copyWith(filters: state.value.filters.copyWith(range: r));
    _debouncer.run(_searchNow);
  }

  void setSort(SortStrategy s) {
    if (state.value.filters.sort.runtimeType == s.runtimeType) return;
    final nextFilters = state.value.filters.copyWith(sort: s);
    final current = state.value.state;
    if (current is SuccessState<Failure, SearchPayload>) {
      final resorted = s.sort([...current.success.items]);
      state.value = state.value.copyWith(
        filters: nextFilters,
        state: SuccessState<Failure, SearchPayload>(current.success.copyWith(items: resorted)),
      );
    } else {
      state.value = state.value.copyWith(filters: nextFilters);
      _debouncer.run(_searchNow);
    }
  }

  Future<void> clearAllFilterSelection() async {
    state.value = state.value.copyWith(filters: const SearchFilters());
    await _searchNow();
  }

  Future<void> toggleFavorite(String id) async {
    final res = await _toggleFav(id);
    res.fold(
      (f) => emit(ShowErrorSnackBar(f.message)),
      (set) => state.value = state.value.copyWith(favorites: set),
    );
  }

  bool hasInfoFor(String bookId) => state.value.byBookId.containsKey(bookId);

  Future<void> resolveFor(BookEntity book) async {
    if (isDisposed || hasInfoFor(book.id)) return;
    final info = await _resolver.resolve(book.title, book.author);
    if (isDisposed || info == null) return;
    final nextMap = copyWithEntry(state.value.byBookId, book.id, info);
    state.value = state.value.copyWith(byBookId: nextMap);
  }

  Future<void> _searchNow() async {
    state.value = state.value.copyWith(state: LoadingState<Failure, SearchPayload>());

    final q = state.value.text.trim();
    final Either<Failure, List<BookEntity>> base = q.isEmpty
        ? await _getAll()
        : await _getByTitle(q);

    base.fold(
      (f) {
        state.value = state.value.copyWith(state: ErrorState<Failure, SearchPayload>(f));
        emit(ShowErrorSnackBar(f.message));
      },
      (list) async {
        final filtered = _applyFilters(list, state.value.filters);
        state.value = state.value.copyWith(
          state: SuccessState<Failure, SearchPayload>(SearchPayload(items: filtered)),
        );
        await _prefetchFor(filtered.take(10));
      },
    );
  }

  List<BookEntity> _applyFilters(List<BookEntity> input, SearchFilters f) {
    BookSpecifications spec = AllowAll();
    spec = spec.and(PublishedInRange.fromEnum(f.range));
    final filtered = input.where(spec.isSatisfiedBy).toList();
    return f.sort.sort(filtered);
  }

  Future<void> _prefetchFor(Iterable<BookEntity> books) async {
    if (isDisposed) return;
    final pairs = books.map((b) => (title: b.title, author: b.author));
    await _resolver.prefetch(pairs);
  }
}
