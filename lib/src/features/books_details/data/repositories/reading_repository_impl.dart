import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/data/datasources/reading/reading_local_data_source.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:dartz/dartz.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl(this._dataSource);
  final ReadingLocalDataSource _dataSource;

  @override
  Future<Either<Failure, bool>> isReading(String id) async {
    try {
      final m = await _dataSource.readAll();
      final v = (m[id] as Map?)?['isReading'] == true;
      return Right(v);
    } catch (e, s) {
      return Left(StorageFailure('Failed to read reading flag', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleReading(String id) async {
    try {
      final m = await _dataSource.readAll();
      final entry = Map<String, dynamic>.from((m[id] as Map?) ?? {});
      final next = !(entry['isReading'] == true);
      entry['isReading'] = next;
      m[id] = entry;
      await _dataSource.writeAll(m);
      return Right(next);
    } catch (e, s) {
      return Left(StorageFailure('Failed to toggle reading', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, int>> getProgress(String id) async {
    try {
      final m = await _dataSource.readAll();
      final p = (m[id] as Map?)?['progress'] as int?;
      return Right((p ?? 0).clamp(0, 100));
    } catch (e, s) {
      return Left(StorageFailure('Failed to read progress', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, Unit>> setProgress(String id, int progress) async {
    try {
      final m = await _dataSource.readAll();
      final entry = Map<String, dynamic>.from((m[id] as Map?) ?? {});
      entry['progress'] = progress.clamp(0, 100);
      m[id] = entry;
      await _dataSource.writeAll(m);
      return const Right(unit);
    } catch (e, s) {
      return Left(StorageFailure('Failed to write progress', cause: e, stackTrace: s));
    }
  }
}
