import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/use_cases/write_reader_settings_use_case.dart';
import 'package:book_library/src/features/reader/domain/value_objects/font_size_object.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReaderSettingsRepository repo;
  late SetReaderSettingsUseCase useCase;

  setUp(() {
    repo = MockReaderSettingsRepository();
    useCase = SetReaderSettingsUseCaseImpl(repo);
  });

  test('retorna Right(void) quando repo.setSettings succeed', () async {
    const entity = ReaderSettingsEntity(fontSize: FontSizeVO(18));
    when(repo.setSettings(entity)).thenAnswer((_) async => const Right(null));

    final r = await useCase(entity);

    expect(r, const Right<Failure, void>(null));
    verify(repo.setSettings(entity)).called(1);
  });

  test('retorna Left(failure) quando repo.setSettings falha', () async {
    final f = const StorageFailure('fail');
    const entity = ReaderSettingsEntity(fontSize: FontSizeVO(18));

    when(repo.setSettings(entity)).thenAnswer((_) async => Left(f));

    final r = await useCase(entity);

    expect(r.isLeft(), true);
    r.fold((l) => expect(l, f), (_) => fail('esperava Left'));
    verify(repo.setSettings(entity)).called(1);
  });
}
