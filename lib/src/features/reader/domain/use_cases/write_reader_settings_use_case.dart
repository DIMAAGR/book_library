import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/repository/reader_repository.dart';
import 'package:dartz/dartz.dart';

abstract class SetReaderSettingsUseCase {
  Future<Either<Failure, void>> call(ReaderSettingsEntity settings);
}

class SetReaderSettingsUseCaseImpl implements SetReaderSettingsUseCase {
  SetReaderSettingsUseCaseImpl(this.repo);
  final ReaderSettingsRepository repo;
  @override
  Future<Either<Failure, void>> call(ReaderSettingsEntity s) => repo.setSettings(s);
}
