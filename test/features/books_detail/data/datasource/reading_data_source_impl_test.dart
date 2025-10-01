import 'dart:convert';

import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/features/books_details/data/datasources/reading/reading_local_data_source.dart';
import 'package:book_library/src/features/books_details/data/datasources/reading/reading_local_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockKeyValueWrapper prefs;
  late ReadingLocalDataSource dataSource;

  late Map<String, String> store;

  setUp(() {
    prefs = MockKeyValueWrapper();
    store = <String, String>{};

    when(prefs.getString(any)).thenAnswer((inv) {
      final k = inv.positionalArguments[0] as String;
      return store[k];
    });

    when(prefs.setString(any, any)).thenAnswer((inv) async {
      final k = inv.positionalArguments[0] as String;
      final v = inv.positionalArguments[1] as String;
      store[k] = v;
      return true;
    });

    when(prefs.remove(any)).thenAnswer((inv) async {
      final k = inv.positionalArguments[0] as String;
      store.remove(k);
      return true;
    });

    dataSource = ReadingLocalDataSourceImpl(prefs);
  });

  group('ReadingLocalDataSourceImpl', () {
    test('estado inicial: isReading=false e progress=0 com storage vazio', () async {
      final r = await dataSource.isReading('id-1');
      final p = await dataSource.getProgress('id-1');

      expect(r, false);
      expect(p, 0);

      verify(prefs.getString(StorageSchema.readingKey)).called(greaterThan(0));
    });

    test('toggleReading adiciona e depois remove o id', () async {
      final afterAdd = await dataSource.toggleReading('book-42');
      expect(afterAdd, true);

      final again = await dataSource.isReading('book-42');
      expect(again, true);

      final afterRemove = await dataSource.toggleReading('book-42');
      expect(afterRemove, false);

      final finalCheck = await dataSource.isReading('book-42');
      expect(finalCheck, false);
    });

    test('setProgress clampa [0,100] e adiciona id ao conjunto quando > 0', () async {
      await dataSource.setProgress('b', -10);
      expect(await dataSource.getProgress('b'), 0);
      expect(await dataSource.isReading('b'), false);

      await dataSource.setProgress('b', 150);
      expect(await dataSource.getProgress('b'), 100);
      expect(await dataSource.isReading('b'), true);

      final raw = store[StorageSchema.readingKey]!;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      expect(decoded.containsKey('readingIds'), true);
      expect(decoded.containsKey('progressById'), true);
    });

    test('persistência: valores sobrevivem a novas instâncias', () async {
      await dataSource.toggleReading('keep');
      await dataSource.setProgress('keep', 33);

      final ds2 = ReadingLocalDataSourceImpl(prefs);
      expect(await ds2.isReading('keep'), true);
      expect(await ds2.getProgress('keep'), 33);
    });

    test('writeAll() sobrescreve todo o estado e readAll() retorna o bruto', () async {
      expect(await dataSource.readAll(), isEmpty);

      final payload = <String, dynamic>{
        'readingIds': ['a', 'b'],
        'progressById': {'a': 10, 'b': 80},
      };
      await dataSource.writeAll(payload);

      final raw = await dataSource.readAll();
      expect(raw, equals(payload));

      expect(await dataSource.isReading('a'), true);
      expect(await dataSource.getProgress('b'), 80);
    });

    test('formato serializado é estável (readingIds: List, progressById: Map)', () async {
      await dataSource.toggleReading('x');
      await dataSource.setProgress('x', 25);

      final raw = store[StorageSchema.readingKey]!;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      expect(decoded['readingIds'], isA<List>());
      expect(List<String>.from(decoded['readingIds'] as List), contains('x'));

      expect(decoded['progressById'], isA<Map>());
      final m = Map<String, dynamic>.from(decoded['progressById'] as Map);
      expect(m['x'], 25);
    });
  });
}
