import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';

class HomeData {
  const HomeData({
    required this.categories,
    required this.activeCategoryId,
    required this.library,
    required this.explore,
  });
  final List<CategoryEntity> categories;
  final String? activeCategoryId;
  final List<BookEntity> library;
  final List<BookEntity> explore;

  HomeData copyWith({
    List<CategoryEntity>? categories,
    String? activeCategoryId,
    List<BookEntity>? library,
    List<BookEntity>? explore,
  }) {
    return HomeData(
      categories: categories ?? this.categories,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      library: library ?? this.library,
      explore: explore ?? this.explore,
    );
  }
}
