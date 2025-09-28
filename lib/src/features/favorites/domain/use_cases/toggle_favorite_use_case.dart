import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/domain/repository/favorites_repository.dart';
import 'package:dartz/dartz.dart';

abstract class ToggleFavoriteUseCase {
  Future<Either<Failure, Set<String>>> call(String bookId);
}

class ToggleFavoriteUseCaseImpl implements ToggleFavoriteUseCase {
  ToggleFavoriteUseCaseImpl(this.repo);
  final FavoritesRepository repo;
  @override
  Future<Either<Failure, Set<String>>> call(String bookId) => repo.toggle(bookId);
}
