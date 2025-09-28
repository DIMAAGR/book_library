import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

class LibraryData extends Equatable {
  const LibraryData({required this.categories, required this.items, this.activeCategoryId});

  final List<CategoryEntity> categories;
  final List<BookEntity> items;
  final String? activeCategoryId;

  LibraryData copyWith({
    List<CategoryEntity>? categories,
    List<BookEntity>? items,
    String? activeCategoryId,
  }) {
    return LibraryData(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
    );
  }

  @override
  List<Object?> get props => [categories, items, activeCategoryId];
}
