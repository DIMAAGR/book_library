import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/domain/repository/favorites_repository.dart';
import 'package:dartz/dartz.dart';

abstract class IsFavoriteUseCase {
  Future<Either<Failure, bool>> call(String bookId);
}

class IsFavoriteUseCaseImpl implements IsFavoriteUseCase {
  IsFavoriteUseCaseImpl(this.repo);
  final FavoritesRepository repo;
  @override
  Future<Either<Failure, bool>> call(String bookId) => repo.isFavorite(bookId);
}
