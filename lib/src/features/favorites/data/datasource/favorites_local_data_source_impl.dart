import 'dart:convert';

import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/features/favorites/data/datasource/favorites_local_data_source.dart';

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this.wrapper);
  final KeyValueWrapper wrapper;

  @override
  Future<Set<String>> readIds() async {
    final raw = wrapper.getString(StorageSchema.favoritesKey);
    if (raw == null || raw.isEmpty) return <String>{};
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => e.toString()).toSet();
  }

  @override
  Future<void> writeIds(Set<String> ids) async {
    final raw = json.encode(ids.toList()..sort());
    await wrapper.setString(StorageSchema.favoritesKey, raw);
  }
}
