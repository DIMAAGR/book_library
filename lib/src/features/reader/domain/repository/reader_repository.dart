import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ReaderSettingsRepository {
  Future<Either<Failure, ReaderSettingsEntity>> getSettings();
  Future<Either<Failure, void>> setSettings(ReaderSettingsEntity settings);
}
