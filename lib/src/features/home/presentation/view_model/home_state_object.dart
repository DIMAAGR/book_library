import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:equatable/equatable.dart';

class HomeStateObject extends Equatable {
  factory HomeStateObject.initial() => HomeStateObject(
    state: InitialState(),
    byBookId: const {},
    categories: const [],
    activeCategoryId: null,
    library: const [],
    explore: const [],
  );

  const HomeStateObject({
    required this.state,
    required this.byBookId,
    required this.categories,
    required this.activeCategoryId,
    required this.library,
    required this.explore,
  });

  final ViewModelState<Failure, HomePayload> state;
  final Map<String, ExternalBookInfoEntity> byBookId;

  final List<CategoryEntity> categories;
  final String? activeCategoryId;
  final List<BookEntity> library;
  final List<BookEntity> explore;

  HomeStateObject copyWith({
    ViewModelState<Failure, HomePayload>? state,
    Map<String, ExternalBookInfoEntity>? byBookId,
    List<CategoryEntity>? categories,
    String? activeCategoryId,
    List<BookEntity>? library,
    List<BookEntity>? explore,
  }) {
    return HomeStateObject(
      state: state ?? this.state,
      byBookId: byBookId ?? this.byBookId,
      categories: categories ?? this.categories,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      library: library ?? this.library,
      explore: explore ?? this.explore,
    );
  }

  @override
  List<Object?> get props => [state, byBookId, categories, activeCategoryId, library, explore];
}

class HomePayload extends Equatable {
  const HomePayload({
    required this.categories,
    required this.activeCategoryId,
    required this.library,
    required this.explore,
  });

  final List<CategoryEntity> categories;
  final String? activeCategoryId;
  final List<BookEntity> library;
  final List<BookEntity> explore;

  HomePayload copyWith({
    List<CategoryEntity>? categories,
    String? activeCategoryId,
    List<BookEntity>? library,
    List<BookEntity>? explore,
  }) {
    return HomePayload(
      categories: categories ?? this.categories,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      library: library ?? this.library,
      explore: explore ?? this.explore,
    );
  }

  @override
  List<Object?> get props => [categories, activeCategoryId, library, explore];
}
