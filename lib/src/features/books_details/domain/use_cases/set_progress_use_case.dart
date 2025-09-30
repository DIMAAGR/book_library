import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:dartz/dartz.dart';

abstract class SetProgressUseCase {
  Future<Either<Failure, Unit>> call(String id, int p);
}

class SetProgressUseCaseImpl implements SetProgressUseCase {
  SetProgressUseCaseImpl(this.repo);
  final ReadingRepository repo;
  @override
  Future<Either<Failure, Unit>> call(String id, int p) => repo.setProgress(id, p);
}
