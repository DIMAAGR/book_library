import 'dart:convert';

import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/features/reader/data/datasource/reader_local_data_source.dart';
import 'package:book_library/src/features/reader/data/datasource/reader_local_data_source_impl.dart';
import 'package:book_library/src/features/reader/data/models/reader_settings_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockKeyValueWrapper wrapper;
  late ReaderSettingsLocalDataSource ds;

  setUp(() {
    wrapper = MockKeyValueWrapper();
    ds = ReaderSettingsLocalDataSourceImpl(wrapper);
  });

  group('ReaderSettingsLocalDataSourceImpl', () {
    test('read() retorna null quando não há nada salvo', () async {
      when(wrapper.getString(StorageSchema.readingSettingsKey)).thenReturn(null);
      final r1 = await ds.read();
      expect(r1, isNull);

      when(wrapper.getString(StorageSchema.readingSettingsKey)).thenReturn('');
      final r2 = await ds.read();
      expect(r2, isNull);

      verify(wrapper.getString(StorageSchema.readingSettingsKey)).called(2);
    });

    test('read() desserializa JSON válido para ReaderSettingsModel', () async {
      final model = const ReaderSettingsModel(fontSize: 18.0, lineHeight: 'comfortable');
      final raw = jsonEncode(model.toJson());

      when(wrapper.getString(StorageSchema.readingSettingsKey)).thenReturn(raw);

      final out = await ds.read();
      expect(out, isNotNull);
      expect(out!.fontSize, 18.0);
      expect(out.lineHeight, 'comfortable');

      verify(wrapper.getString(StorageSchema.readingSettingsKey)).called(1);
    });

    test('write() serializa e persiste usando a chave versionada', () async {
      final model = const ReaderSettingsModel(fontSize: 22.0, lineHeight: 'spacious');

      when(wrapper.setString(any, any)).thenAnswer((_) async => true);

      await ds.write(model);

      final captured = verify(wrapper.setString(captureAny, captureAny)).captured;

      expect(captured[0], StorageSchema.readingSettingsKey);
      final writtenJson = captured[1] as String;
      final map = jsonDecode(writtenJson) as Map<String, dynamic>;
      expect(map['fontSize'], 22.0);
      expect(map['lineHeight'], 'spacious');
    });
  });
}
