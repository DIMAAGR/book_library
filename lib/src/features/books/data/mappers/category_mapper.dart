import 'package:book_library/src/features/books/data/models/category_model.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';

abstract class CategoryMapper {
  static CategoryEntity toEntity(CategoryModel model) {
    return CategoryEntity(id: model.id, name: model.name);
  }

  static CategoryModel toModel(CategoryEntity entity) {
    return CategoryModel(id: entity.id, name: entity.name);
  }
}
