import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:dartz/dartz.dart';

abstract class ToggleReadingUseCase {
  Future<Either<Failure, bool>> call(String id);
}

class ToggleReadingUseCaseImpl implements ToggleReadingUseCase {
  ToggleReadingUseCaseImpl(this.repo);
  final ReadingRepository repo;
  @override
  Future<Either<Failure, bool>> call(String id) => repo.toggleReading(id);
}
