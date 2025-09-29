import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/strategy/picks_strategy.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/search/domain/specifications/book_specifications.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:flutter/foundation.dart';

class ExploreViewModel {
  ExploreViewModel(
    this.getAllBooksUseCase,
    this.getFavoritesIdsUseCase,
    this.externalBookInfoResolver,
    this.toggleFavoriteUseCase, {
    PickStrategy? newReleasesStrategy,
    PickStrategy? popularBooksStrategy,
  }) : pickNewReleasesStrategy = newReleasesStrategy ?? PickNewReleases(limit: 12),
       pickPopularBooksStrategy = popularBooksStrategy ?? PickPopularAZ(limit: 10);

  final GetAllBooksUseCase getAllBooksUseCase;
  final GetFavoritesIdsUseCase getFavoritesIdsUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final ExternalBookInfoResolver externalBookInfoResolver;

  final PickStrategy pickNewReleasesStrategy;
  final PickStrategy pickPopularBooksStrategy;

  final ValueNotifier<ExplorerState> stateNotifier = ValueNotifier(ExplorerState.initial());
  final ValueNotifier<UiEvent?> eventNotifier = ValueNotifier<UiEvent?>(null);

  bool _isDisposed = false;

  ValueListenable<ExplorerState> get state => stateNotifier;
  ValueListenable<UiEvent?> get events => eventNotifier;

  void _updateState(ExplorerState nextState) {
    if (_isDisposed) return;
    stateNotifier.value = nextState;
  }

  void _emitEvent(UiEvent event) {
    if (_isDisposed) return;
    eventNotifier.value = event;
  }

  void consumeEvent() => eventNotifier.value = null;

  Future<void> init() async {
    _updateState(stateNotifier.value.copyWith(state: LoadingState()));
    await _loadFavorites();
    await _loadAllBooks();
  }

  Future<void> _loadFavorites() async {
    final result = await getFavoritesIdsUseCase();
    result.fold(
      (failure) => _emitEvent(ShowSnackBar(failure.message)),
      (favorites) => _updateState(stateNotifier.value.copyWith(favorites: favorites)),
    );
  }

  Future<void> _loadAllBooks() async {
    final result = await getAllBooksUseCase();
    await result.fold(
      (Failure failure) async {
        _updateState(stateNotifier.value.copyWith(state: ErrorState(failure)));
        _emitEvent(ShowErrorSnackBar(failure.message));
      },
      (List<BookEntity> allBooks) async {
        final newReleases = pickNewReleasesStrategy.pick(allBooks);
        final popularBooks = pickPopularBooksStrategy.pick(allBooks);

        final favoriteAuthorsLower = allBooks
            .where((book) => stateNotifier.value.favorites.contains(book.id))
            .map((book) => book.author.toLowerCase())
            .toSet();

        final similarBooks = PickSimilarToFavorites(
          favoriteIds: stateNotifier.value.favorites,
          favoriteAuthorsLower: favoriteAuthorsLower,
        ).pick(allBooks);

        _updateState(
          stateNotifier.value.copyWith(
            state: SuccessState(allBooks),
            newReleases: newReleases,
            popularTop10: popularBooks,
            similarToFavorites: similarBooks,
          ),
        );

        _prefetchCovers([...newReleases, ...popularBooks, ...similarBooks].take(20));
      },
    );
  }

  Future<void> toggleFavorite(String bookId) async {
    final res = await toggleFavoriteUseCase(bookId);
    res.fold(
      (f) => _emitEvent(ShowErrorSnackBar(f.message)),
      (updated) => _updateState(stateNotifier.value.copyWith(favorites: updated)),
    );
  }

  List<BookEntity> allBooksFiltered() {
    final s = stateNotifier.value.state;
    final all = (s is SuccessState)
        ? ((s as SuccessState).success as List<BookEntity>)
        : const <BookEntity>[];

    final q = stateNotifier.value.query;

    final spec = AllowAll()
        .and(TitleContains(q.title))
        .and(AuthorContains(q.author))
        .and(PublisherContains(q.publisher))
        .and(PublishedInRange.fromEnum(q.publishedRange));

    final filtered = all.where(spec.isSatisfiedBy).toList();
    return q.sort.sort(filtered);
  }

  void updateQuery(BookQuery nextQuery) =>
      _updateState(stateNotifier.value.copyWith(query: nextQuery));

  Future<void> _prefetchCovers(Iterable<BookEntity> books) async {
    try {
      for (final book in books) {
        if (_isDisposed) return;
        final info = await externalBookInfoResolver.resolve(book.title, book.author);
        if (_isDisposed || info == null) continue;

        final updatedBookInfoMap = Map<String, ExternalBookInfoEntity>.from(
          stateNotifier.value.byBookId,
        )..[book.id] = info;

        _updateState(stateNotifier.value.copyWith(byBookId: updatedBookInfoMap));
      }
    } catch (_) {
      _emitEvent(ShowSnackBar('Failed to prefetch covers'));
    }
  }

  void dispose() {
    _isDisposed = true;
    stateNotifier.dispose();
    eventNotifier.dispose();
  }
}
