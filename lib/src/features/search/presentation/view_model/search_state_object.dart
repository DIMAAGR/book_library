import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/types/book_info_id.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:equatable/equatable.dart';

class SearchStateObject extends Equatable {
  factory SearchStateObject.initial() => SearchStateObject(
    state: InitialState<Failure, SearchPayload>(),
    byBookId: const {},
    text: '',
    filters: const SearchFilters(),
    favorites: const {},
  );

  const SearchStateObject({
    required this.state,
    required this.byBookId,
    required this.text,
    required this.filters,
    required this.favorites,
  });

  final ViewModelState<Failure, SearchPayload> state;
  final BookInfoById byBookId;
  final String text;
  final SearchFilters filters;
  final Set<String> favorites;

  SearchStateObject copyWith({
    ViewModelState<Failure, SearchPayload>? state,
    BookInfoById? byBookId,
    String? text,
    SearchFilters? filters,
    Set<String>? favorites,
  }) {
    return SearchStateObject(
      state: state ?? this.state,
      byBookId: byBookId ?? this.byBookId,
      text: text ?? this.text,
      filters: filters ?? this.filters,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [state, byBookId, text, filters, favorites];
}

class SearchPayload extends Equatable {
  const SearchPayload({required this.items});

  final List<BookEntity> items;

  SearchPayload copyWith({List<BookEntity>? items}) {
    return SearchPayload(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}

class SearchFilters extends Equatable {
  const SearchFilters({this.range = PublishedRange.any, this.sort = const SortByAZ()});
  final PublishedRange range;
  final SortStrategy sort;

  SearchFilters copyWith({PublishedRange? range, SortStrategy? sort}) =>
      SearchFilters(range: range ?? this.range, sort: sort ?? this.sort);

  @override
  List<Object?> get props => [range, sort];
}
