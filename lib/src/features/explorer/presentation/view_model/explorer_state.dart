import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:equatable/equatable.dart';

class ExplorerState extends Equatable {
  factory ExplorerState.initial() => ExplorerState(
    state: InitialState(),
    favorites: const {},
    byBookId: const {},
    query: const BookQuery(),
    newReleases: const [],
    popularTop10: const [],
    similarToFavorites: const [],
  );
  const ExplorerState({
    required this.state,
    required this.favorites,
    required this.byBookId,
    required this.query,
    required this.newReleases,
    required this.popularTop10,
    required this.similarToFavorites,
  });

  final ViewModelState<Failure, List<BookEntity>> state;
  final Set<String> favorites;
  final Map<String, ExternalBookInfoEntity> byBookId;
  final BookQuery query;

  final List<BookEntity> newReleases;
  final List<BookEntity> popularTop10;
  final List<BookEntity> similarToFavorites;

  ExplorerState copyWith({
    ViewModelState<Failure, List<BookEntity>>? state,
    Set<String>? favorites,
    Map<String, ExternalBookInfoEntity>? byBookId,
    BookQuery? query,
    List<BookEntity>? newReleases,
    List<BookEntity>? popularTop10,
    List<BookEntity>? similarToFavorites,
  }) {
    return ExplorerState(
      state: state ?? this.state,
      favorites: favorites ?? this.favorites,
      byBookId: byBookId ?? this.byBookId,
      query: query ?? this.query,
      newReleases: newReleases ?? this.newReleases,
      popularTop10: popularTop10 ?? this.popularTop10,
      similarToFavorites: similarToFavorites ?? this.similarToFavorites,
    );
  }

  @override
  List<Object?> get props => [
    state,
    favorites,
    byBookId,
    query,
    newReleases,
    popularTop10,
    similarToFavorites,
  ];
}
