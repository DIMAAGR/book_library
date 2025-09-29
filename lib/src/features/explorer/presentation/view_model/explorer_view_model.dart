import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
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

class ExploreViewModel extends BaseViewModel {
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
  ValueListenable<ExplorerState> get state => stateNotifier;

  void _set(ExplorerState next) {
    if (isDisposed) return;
    stateNotifier.value = next;
  }

  Future<void> init() async {
    _set(stateNotifier.value.copyWith(state: LoadingState()));
    await _loadFavorites();
    await _loadAllBooks();
  }

  Future<void> _loadFavorites() async {
    final res = await getFavoritesIdsUseCase();
    res.fold(
      (f) => emit(ShowSnackBar(f.message)),
      (ids) => _set(stateNotifier.value.copyWith(favorites: ids)),
    );
  }

  Future<void> _loadAllBooks() async {
    final res = await getAllBooksUseCase();
    await res.fold(
      (f) {
        _set(stateNotifier.value.copyWith(state: ErrorState(f)));
        emit(ShowErrorSnackBar(f.message));
      },
      (all) async {
        final newReleases = pickNewReleasesStrategy.pick(all);
        final popular = pickPopularBooksStrategy.pick(all);
        final favAuthors = all
            .where((b) => stateNotifier.value.favorites.contains(b.id))
            .map((b) => b.author.toLowerCase())
            .toSet();

        final similar = PickSimilarToFavorites(
          favoriteIds: stateNotifier.value.favorites,
          favoriteAuthorsLower: favAuthors,
        ).pick(all);

        _set(
          stateNotifier.value.copyWith(
            state: SuccessState<Failure, List<BookEntity>>(all),
            newReleases: newReleases,
            popularTop10: popular,
            similarToFavorites: similar,
          ),
        );

        _prefetchCovers([...newReleases, ...popular, ...similar].take(20));
      },
    );
  }

  Future<void> toggleFavorite(String id) async {
    final res = await toggleFavoriteUseCase(id);
    res.fold(
      (f) => emit(ShowErrorSnackBar(f.message)),
      (updated) => _set(stateNotifier.value.copyWith(favorites: updated)),
    );
  }

  List<BookEntity> allBooksFiltered() {
    final s = stateNotifier.value.state;
    final all = s.successOrNull ?? const <BookEntity>[];
    final q = stateNotifier.value.query;

    final spec = AllowAll()
        .and(TitleContains(q.title))
        .and(AuthorContains(q.author))
        .and(PublisherContains(q.publisher))
        .and(PublishedInRange.fromEnum(q.publishedRange));

    final filtered = all.where(spec.isSatisfiedBy).toList();
    return q.sort.sort(filtered);
  }

  void updateQuery(BookQuery next) => _set(stateNotifier.value.copyWith(query: next));

  Future<void> _prefetchCovers(Iterable<BookEntity> books) async {
    try {
      for (final b in books) {
        if (isDisposed) return;
        final info = await externalBookInfoResolver.resolve(b.title, b.author);
        if (isDisposed || info == null) continue;
        final nextMap = Map<String, ExternalBookInfoEntity>.from(stateNotifier.value.byBookId)
          ..[b.id] = info;
        _set(stateNotifier.value.copyWith(byBookId: nextMap));
      }
    } catch (_) {
      emit(ShowSnackBar('Failed to prefetch covers'));
    }
  }

  @override
  void dispose() {
    stateNotifier.dispose();
    super.dispose();
  }
}
