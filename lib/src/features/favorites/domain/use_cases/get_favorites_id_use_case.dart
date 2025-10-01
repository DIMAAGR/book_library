import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/domain/repository/favorites_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetFavoritesIdsUseCase {
  Future<Either<Failure, Set<String>>> call();
}

class GetFavoritesIdsUseCaseImpl implements GetFavoritesIdsUseCase {
  GetFavoritesIdsUseCaseImpl(this.repo);
  final FavoritesRepository repo;
  @override
  Future<Either<Failure, Set<String>>> call() => repo.getAllIds();
}
