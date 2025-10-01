import 'package:book_library/src/core/failures/failures.dart';
import 'package:dartz/dartz.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, bool>> isDone();
  Future<Either<Failure, Unit>> setDone(bool value);
}
