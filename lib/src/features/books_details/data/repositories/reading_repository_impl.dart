import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/data/datasources/reading/reading_local_data_source.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:dartz/dartz.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl(this._dataSource);
  final ReadingLocalDataSource _dataSource;

  @override
  Future<Either<Failure, bool>> isReading(String bookId) async {
    try {
      return Right(await _dataSource.isReading(bookId));
    } catch (e, s) {
      return Left(StorageFailure('read isReading', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleReading(String bookId) async {
    try {
      return Right(await _dataSource.toggleReading(bookId));
    } catch (e, s) {
      return Left(StorageFailure('toggle reading', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, int>> getProgress(String bookId) async {
    try {
      return Right(await _dataSource.getProgress(bookId));
    } catch (e, s) {
      return Left(StorageFailure('get progress', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, Unit>> setProgress(String bookId, int percent) async {
    try {
      await _dataSource.setProgress(bookId, percent);
      return const Right(unit);
    } catch (e, s) {
      return Left(StorageFailure('set progress', cause: e, stackTrace: s));
    }
  }
}
