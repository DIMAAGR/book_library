import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:dartz/dartz.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAll();
}
