import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:book_library/src/features/favorites/domain/repository/favorites_repository.dart';
import 'package:dartz/dartz.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this.local);
  final FavoritesLocalDataSource local;

  @override
  Future<Either<Failure, Set<String>>> getAllIds() async {
    try {
      final ids = await local.readIds();
      return Right(ids);
    } catch (e, s) {
      return Left(StorageFailure('Failed to read favorites', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, void>> setAllIds(Set<String> ids) async {
    try {
      await local.writeIds(ids);
      return const Right(null);
    } catch (e, s) {
      return Left(StorageFailure('Failed to write favorites', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String bookId) async {
    try {
      final ids = await local.readIds();
      return Right(ids.contains(bookId));
    } catch (e, s) {
      return Left(StorageFailure('Failed to read favorites', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> toggle(String bookId) async {
    try {
      final ids = await local.readIds();
      if (ids.contains(bookId)) {
        ids.remove(bookId);
      } else {
        ids.add(bookId);
      }
      await local.writeIds(ids);
      return Right(ids);
    } catch (e, s) {
      return Left(StorageFailure('Failed to toggle favorite', cause: e, stackTrace: s));
    }
  }
}
