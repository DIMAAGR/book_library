import 'package:book_library/src/core/failures/failures.dart';
import 'package:dartz/dartz.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, Set<String>>> getAllIds();
  Future<Either<Failure, void>> setAllIds(Set<String> ids);
  Future<Either<Failure, bool>> isFavorite(String bookId);
  Future<Either<Failure, Set<String>>> toggle(String bookId);
}
