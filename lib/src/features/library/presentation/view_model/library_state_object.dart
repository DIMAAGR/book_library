import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:equatable/equatable.dart';

class LibraryStateObject extends Equatable {
  factory LibraryStateObject.initial() => LibraryStateObject(
    state: InitialState(),
    byBookId: const {},
    categories: const [],
    items: const [],
    activeCategoryId: null,
  );

  const LibraryStateObject({
    required this.state,
    required this.byBookId,
    required this.categories,
    required this.items,
    required this.activeCategoryId,
  });

  final ViewModelState<Failure, LibraryPayload> state;
  final Map<String, ExternalBookInfoEntity> byBookId;

  final List<CategoryEntity> categories;
  final List<BookEntity> items;
  final String? activeCategoryId;

  LibraryStateObject copyWith({
    ViewModelState<Failure, LibraryPayload>? state,
    Map<String, ExternalBookInfoEntity>? byBookId,
    List<CategoryEntity>? categories,
    List<BookEntity>? items,
    String? activeCategoryId,
  }) {
    return LibraryStateObject(
      state: state ?? this.state,
      byBookId: byBookId ?? this.byBookId,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
    );
  }

  @override
  List<Object?> get props => [state, byBookId, categories, items, activeCategoryId];
}

class LibraryPayload extends Equatable {
  const LibraryPayload({
    required this.categories,
    required this.items,
    required this.activeCategoryId,
  });

  final List<CategoryEntity> categories;
  final List<BookEntity> items;
  final String? activeCategoryId;

  LibraryPayload copyWith({
    List<CategoryEntity>? categories,
    List<BookEntity>? items,
    String? activeCategoryId,
  }) {
    return LibraryPayload(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
    );
  }

  @override
  List<Object?> get props => [categories, items, activeCategoryId];
}
