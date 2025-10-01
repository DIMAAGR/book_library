import 'dart:convert';
import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/features/reader/data/datasource/reader_local_data_source.dart';
import 'package:book_library/src/features/reader/data/models/reader_settings_model.dart';

class ReaderSettingsLocalDataSourceImpl implements ReaderSettingsLocalDataSource {
  ReaderSettingsLocalDataSourceImpl(this.wrapper);
  final KeyValueWrapper wrapper;

  static const _key = StorageSchema.readingSettingsKey;

  @override
  Future<ReaderSettingsModel?> read() async {
    final raw = wrapper.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    return ReaderSettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> write(ReaderSettingsModel model) async {
    await wrapper.setString(_key, jsonEncode(model.toJson()));
  }
}
