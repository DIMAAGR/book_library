import 'dart:convert';
import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/features/books_details/data/datasources/reading/reading_local_data_source.dart';

class ReadingLocalDataSourceImpl implements ReadingLocalDataSource {
  ReadingLocalDataSourceImpl(this._wrapper);
  final KeyValueWrapper _wrapper;

  static String get _readingStateKey => StorageSchema.readingKey;

  Future<Map<String, dynamic>> _loadState() async {
    final raw = _wrapper.getString(_readingStateKey);
    if (raw == null || raw.isEmpty) {
      return {'readingIds': <String>[], 'progressById': <String, int>{}};
    }
    final Map<String, dynamic> decoded = jsonDecode(raw);
    return {
      'readingIds': (decoded['readingIds'] as List?)?.cast<String>() ?? <String>[],
      'progressById':
          (decoded['progressById'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)) ??
          <String, int>{},
    };
  }

  Future<void> _saveState({
    required Set<String> readingIds,
    required Map<String, int> progressById,
  }) async {
    final payload = jsonEncode({'readingIds': readingIds.toList(), 'progressById': progressById});
    await _wrapper.setString(_readingStateKey, payload);
  }

  @override
  Future<bool> isReading(String id) async {
    final state = await _loadState();
    final ids = (state['readingIds'] as List<String>).toSet();
    return ids.contains(id);
  }

  @override
  Future<bool> toggleReading(String id) async {
    final state = await _loadState();
    final ids = (state['readingIds'] as List<String>).toSet();
    final progress = Map<String, int>.from(state['progressById'] as Map<String, int>);

    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }

    await _saveState(readingIds: ids, progressById: progress);
    return ids.contains(id);
  }

  @override
  Future<int> getProgress(String id) async {
    final state = await _loadState();
    final progress = Map<String, int>.from(state['progressById'] as Map<String, int>);
    return progress[id] ?? 0;
  }

  @override
  Future<void> setProgress(String id, int percent) async {
    final state = await _loadState();
    final ids = (state['readingIds'] as List<String>).toSet();
    final progress = Map<String, int>.from(state['progressById'] as Map<String, int>);

    progress[id] = percent.clamp(0, 100);
    if (percent > 0) ids.add(id);

    await _saveState(readingIds: ids, progressById: progress);
  }
}
