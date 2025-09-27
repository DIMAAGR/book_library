import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books/domain/repositories/categories_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetCategoriesUseCase {
  const GetCategoriesUseCase();

  Future<Either<Failure, List<CategoryEntity>>> call();
}

class GetCategoriesUseCaseImpl extends GetCategoriesUseCase {
  const GetCategoriesUseCaseImpl(this.repository);
  final CategoriesRepository repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getAll();
  }
}
