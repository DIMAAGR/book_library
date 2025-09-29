import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:equatable/equatable.dart';

class FavoritesStateObject extends Equatable {
  factory FavoritesStateObject.initial() => FavoritesStateObject(
    state: InitialState(),
    favorites: const {},
    byBookId: const {},
    items: const [],
    sort: const SortByAZ(),
  );

  const FavoritesStateObject({
    required this.state,
    required this.favorites,
    required this.byBookId,
    required this.items,
    required this.sort,
  });

  final ViewModelState<Failure, List<BookEntity>> state;
  final Set<String> favorites;
  final Map<String, ExternalBookInfoEntity> byBookId;
  final List<BookEntity> items;
  final SortStrategy sort;

  FavoritesStateObject copyWith({
    ViewModelState<Failure, List<BookEntity>>? state,
    Set<String>? favorites,
    Map<String, ExternalBookInfoEntity>? byBookId,
    List<BookEntity>? items,
    SortStrategy? sort,
  }) {
    return FavoritesStateObject(
      state: state ?? this.state,
      favorites: favorites ?? this.favorites,
      byBookId: byBookId ?? this.byBookId,
      items: items ?? this.items,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [state, favorites, byBookId, items, sort];
}
