import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/reader/data/datasource/reader_local_data_source.dart';
import 'package:book_library/src/features/reader/data/mappers/reader_settings_mapper.dart';
import 'package:book_library/src/features/reader/data/models/reader_settings_model.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/repository/reader_repository.dart';
import 'package:dartz/dartz.dart';

class ReaderSettingsRepositoryImpl implements ReaderSettingsRepository {
  ReaderSettingsRepositoryImpl(this.local);
  final ReaderSettingsLocalDataSource local;

  @override
  Future<Either<Failure, ReaderSettingsEntity>> getSettings() async {
    try {
      final ReaderSettingsModel? m = await local.read();
      if (m == null) return const Right(ReaderSettingsEntity());
      return Right(ReaderSettingsMapper.toEntity(m));
    } catch (e, s) {
      return Left(StorageFailure('Failed to read reader settings', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, void>> setSettings(ReaderSettingsEntity s) async {
    try {
      await local.write(ReaderSettingsMapper.toModel(s));
      return const Right(null);
    } catch (e, sTrace) {
      return Left(StorageFailure('Failed to save reader settings', cause: e, stackTrace: sTrace));
    }
  }
}
