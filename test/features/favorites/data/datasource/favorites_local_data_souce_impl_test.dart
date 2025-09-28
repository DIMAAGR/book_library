import 'dart:convert';

import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/features/favorites/data/datasource/favorites_local_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late FavoritesLocalDataSourceImpl dataSource;
  late MockKeyValueWrapper mockWrapper;

  setUp(() {
    mockWrapper = MockKeyValueWrapper();
    dataSource = FavoritesLocalDataSourceImpl(mockWrapper);
  });

  test('readIds: retorna set vazio quando chave não existe', () async {
    when(mockWrapper.getString(StorageSchema.favoritesKey)).thenReturn(null);

    final res = await dataSource.readIds();
    expect(res, isEmpty);
  });

  test('readIds: decodifica json e retorna Set<String>', () async {
    when(mockWrapper.getString(StorageSchema.favoritesKey)).thenReturn(jsonEncode(['a', 'b']));

    final res = await dataSource.readIds();
    expect(res, {'a', 'b'});
  });

  test('writeIds: codifica ordenado e salva no wrapper', () async {
    when(mockWrapper.setString(any, any)).thenAnswer((_) async => true);

    await dataSource.writeIds({'b', 'a'});
    final captured =
        verify(mockWrapper.setString(StorageSchema.favoritesKey, captureAny)).captured.single
            as String;

    // deve estar ordenado
    expect(captured, jsonEncode(['a', 'b']));
  });
}
