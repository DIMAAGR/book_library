import 'package:book_library/src/core/failures/failures.dart';
import 'package:dartz/dartz.dart';

abstract class ReadingRepository {
  Future<Either<Failure, bool>> isReading(String bookId);
  Future<Either<Failure, bool>> toggleReading(String bookId);
  Future<Either<Failure, int>> getProgress(String bookId);
  Future<Either<Failure, Unit>> setProgress(String bookId, int percent);
}
