import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/repository/reader_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetReaderSettingsUseCase {
  Future<Either<Failure, ReaderSettingsEntity>> call();
}

class GetReaderSettingsUseCaseImpl implements GetReaderSettingsUseCase {
  GetReaderSettingsUseCaseImpl(this.repo);
  final ReaderSettingsRepository repo;
  @override
  Future<Either<Failure, ReaderSettingsEntity>> call() => repo.getSettings();
}
