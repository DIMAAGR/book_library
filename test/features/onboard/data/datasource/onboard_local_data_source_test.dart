import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockKeyValueWrapper mockStore;
  late OnboardingLocalDataSourceImpl dataSource;

  setUp(() {
    mockStore = MockKeyValueWrapper();
    dataSource = OnboardingLocalDataSourceImpl(mockStore);
  });

  group('isDone', () {
    test('retorna true quando valor armazenado é "true"', () async {
      when(mockStore.getString(StorageSchema.onboardingDoneKey)).thenReturn('true');

      final result = await dataSource.isDone();

      expect(result, true);
      verify(mockStore.getString(StorageSchema.onboardingDoneKey)).called(1);
    });

    test('retorna false quando valor armazenado é "false"', () async {
      when(mockStore.getString(StorageSchema.onboardingDoneKey)).thenReturn('false');

      final result = await dataSource.isDone();

      expect(result, false);
    });

    test('retorna false quando não existe valor', () async {
      when(mockStore.getString(StorageSchema.onboardingDoneKey)).thenReturn(null);

      final result = await dataSource.isDone();

      expect(result, false);
    });
  });

  group('setDone', () {
    test('salva true corretamente', () async {
      when(
        mockStore.setString(StorageSchema.onboardingDoneKey, 'true'),
      ).thenAnswer((_) async => true);

      await dataSource.setDone(true);

      verify(mockStore.setString(StorageSchema.onboardingDoneKey, 'true')).called(1);
    });

    test('salva false corretamente', () async {
      when(
        mockStore.setString(StorageSchema.onboardingDoneKey, 'false'),
      ).thenAnswer((_) async => true);

      await dataSource.setDone(false);

      verify(mockStore.setString(StorageSchema.onboardingDoneKey, 'false')).called(1);
    });
  });
}
