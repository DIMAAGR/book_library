import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_book_by_title_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/search/domain/specifications/book_specifications.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:book_library/src/features/search/presentation/debounce/debouncer.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class SearchFilters {
  const SearchFilters({this.range = PublishedRange.any, this.sort = const SortByAZ()});
  final PublishedRange range;
  final SortStrategy sort;

  SearchFilters copyWith({PublishedRange? range, SortStrategy? sort}) =>
      SearchFilters(range: range ?? this.range, sort: sort ?? this.sort);
}

class SearchViewModel {
  SearchViewModel(this._getAll, this._getByTitle, this._getFavs, this._toggleFav, this._resolver)
    : _debouncer = Debouncer();

  bool _isDisposed = false;

  final GetAllBooksUseCase _getAll;
  final GetBookByTitleUseCase _getByTitle;
  final GetFavoritesIdsUseCase _getFavs;
  final ToggleFavoriteUseCase _toggleFav;
  final ExternalBookInfoResolver _resolver;

  final Debouncer _debouncer;

  final ValueNotifier<ViewModelState<Failure, List<BookEntity>>> state =
      ValueNotifier<ViewModelState<Failure, List<BookEntity>>>(InitialState());

  final ValueNotifier<UiEvent?> event = ValueNotifier<UiEvent?>(null);
  final ValueNotifier<String> text = ValueNotifier<String>('');
  final ValueNotifier<SearchFilters> filters = ValueNotifier<SearchFilters>(const SearchFilters());
  final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  final ValueNotifier<PublishedRange> range = ValueNotifier(PublishedRange.any);
  final ValueNotifier<SortStrategy> sort = ValueNotifier<SortStrategy>(const SortByAZ());

  final ValueNotifier<Map<String, ExternalBookInfoEntity>> byBookId = ValueNotifier(
    <String, ExternalBookInfoEntity>{},
  );

  Future<void> init() async {
    final favs = await _getFavs();
    favs.fold((f) => event.value = ShowErrorSnackBar(f.message), (set) => favorites.value = set);
    await _searchNow();
  }

  Future<void> applyCurrentFilterSelection() async {
    filters.value = filters.value.copyWith(range: range.value, sort: sort.value);
    await _searchNow();
  }

  Future<void> clearAllFilterSelection() async {
    range.value = PublishedRange.any;
    sort.value = const SortByAZ();
    filters.value = const SearchFilters();
    await _searchNow();
  }

  void onTextChanged(String v) {
    text.value = v;
    _debouncer.run(_searchNow);
  }

  Future<void> toggleFavorite(String id) async {
    final res = await _toggleFav(id);
    res.fold((f) => event.value = ShowErrorSnackBar(f.message), (set) => favorites.value = set);
  }

  bool hasInfoFor(String bookId) => byBookId.value.containsKey(bookId);

  Future<void> resolveFor(BookEntity book) async {
    if (_isDisposed || hasInfoFor(book.id)) return;
    final info = await _resolver.resolve(book.title, book.author);
    if (_isDisposed) return;
    if (info != null) {
      final next = Map<String, ExternalBookInfoEntity>.from(byBookId.value);
      next[book.id] = info;
      byBookId.value = next;
    }
  }

  Future<void> _prefetchFor(Iterable<BookEntity> books) async {
    if (_isDisposed) return;
    final pairs = books.map((b) => (title: b.title, author: b.author));
    await _resolver.prefetch(pairs);
  }

  Future<void> _searchNow() async {
    state.value = LoadingState();

    final String q = text.value.trim();
    final Either<Failure, List<BookEntity>> base = q.isEmpty
        ? await _getAll()
        : await _getByTitle(q);

    base.fold(
      (f) {
        state.value = ErrorState(f);
        event.value = ShowErrorSnackBar(f.message);
      },
      (list) async {
        final filtered = _applyFilters(list, filters.value);
        state.value = SuccessState(filtered);

        await _prefetchFor(filtered.take(10));
      },
    );
  }

  List<BookEntity> _applyFilters(List<BookEntity> input, SearchFilters f) {
    BookSpecifications spec = _AllowAll();
    spec = spec.and(PublishedInRange.fromEnum(f.range));
    final filtered = input.where(spec.isSatisfiedBy).toList();
    return f.sort.sort(filtered);
  }

  void consumeEvent() => event.value = null;

  void dispose() {
    _isDisposed = true;
    _debouncer.dispose();

    state.dispose();
    event.dispose();
    text.dispose();
    filters.dispose();
  }
}

class _AllowAll extends BookSpecifications {
  @override
  bool isSatisfiedBy(BookEntity b) => true;
}
