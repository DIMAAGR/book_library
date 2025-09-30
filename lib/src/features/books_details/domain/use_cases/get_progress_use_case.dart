import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetProgressUseCase {
  Future<Either<Failure, int>> call(String id);
}

class GetProgressUseCaseImpl implements GetProgressUseCase {
  GetProgressUseCaseImpl(this.repo);
  final ReadingRepository repo;
  @override
  Future<Either<Failure, int>> call(String id) => repo.getProgress(id);
}
