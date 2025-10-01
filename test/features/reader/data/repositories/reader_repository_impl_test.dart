import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/reader/data/mappers/reader_settings_mapper.dart';
import 'package:book_library/src/features/reader/data/models/reader_settings_model.dart';
import 'package:book_library/src/features/reader/data/repository/reader_repository_impl.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/repository/reader_repository.dart';
import 'package:book_library/src/features/reader/domain/value_objects/font_size_object.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late ReaderSettingsRepository repo;
  late MockReaderSettingsLocalDataSource local;

  setUp(() {
    local = MockReaderSettingsLocalDataSource();
    repo = ReaderSettingsRepositoryImpl(local);
  });

  group('getSettings', () {
    test('retorna Right(ReaderSettingsEntity default) quando local.read() == null', () async {
      when(local.read()).thenAnswer((_) async => null);

      final r = await repo.getSettings();

      expect(r, const Right<Failure, ReaderSettingsEntity>(ReaderSettingsEntity()));
      verify(local.read()).called(1);
      verifyNoMoreInteractions(local);
    });

    test('retorna Right(entity mapeada) quando local.read() retorna model', () async {
      const model = ReaderSettingsModel(fontSize: 18.0, lineHeight: 'comfortable');
      when(local.read()).thenAnswer((_) async => model);

      final r = await repo.getSettings();

      final expected = ReaderSettingsMapper.toEntity(model);
      expect(r, Right<Failure, ReaderSettingsEntity>(expected));
      verify(local.read()).called(1);
      verifyNoMoreInteractions(local);
    });

    test('retorna Left(StorageFailure) quando local.read() lança', () async {
      when(local.read()).thenThrow(Exception('boom'));

      final r = await repo.getSettings();

      expect(r.isLeft(), true);
      r.fold((l) => expect(l, isA<StorageFailure>()), (_) => fail('deveria ter retornado Left'));
      verify(local.read()).called(1);
      verifyNoMoreInteractions(local);
    });
  });

  group('setSettings', () {
    test('persiste via local.write(model mapeado) e retorna Right(null)', () async {
      const entity = ReaderSettingsEntity();
      final model = ReaderSettingsMapper.toModel(entity);

      when(local.write(any)).thenAnswer((_) async {});

      final r = await repo.setSettings(entity);

      expect(r, const Right<Failure, void>(null));
      verify(local.write(model)).called(1);
      verifyNoMoreInteractions(local);
    });

    test('retorna Left(StorageFailure) quando local.write() lança', () async {
      const entity = ReaderSettingsEntity(fontSize: FontSizeVO(20));
      when(local.write(any)).thenThrow(Exception('write fail'));

      final r = await repo.setSettings(entity);

      expect(r.isLeft(), true);
      r.fold((l) => expect(l, isA<StorageFailure>()), (_) => fail('deveria ter retornado Left'));
      verify(local.write(ReaderSettingsMapper.toModel(entity))).called(1);
      verifyNoMoreInteractions(local);
    });
  });
}
