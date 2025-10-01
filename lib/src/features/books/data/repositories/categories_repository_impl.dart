import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/data/datasources/fake_remote_data_source/categories_fake_data_source.dart';
import 'package:book_library/src/features/books/data/mappers/category_mapper.dart';
import 'package:book_library/src/features/books/data/models/category_model.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books/domain/repositories/categories_repository.dart';
import 'package:dartz/dartz.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl(this.dataSource);
  final CategoriesFakeDataSource dataSource;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAll() async {
    try {
      final raw = await dataSource.fetchCategories();
      final entities = raw
          .map((m) => CategoryMapper.toEntity(CategoryModel.fromJson(m)))
          .toList(growable: false);
      return Right(entities);
    } catch (e, s) {
      return Left(FakeFailure('Failed to load categories', cause: e, stackTrace: s));
    }
  }
}
