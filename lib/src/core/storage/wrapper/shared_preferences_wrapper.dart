import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueWrapper {
  Future<bool> setString(String key, String value);
  String? getString(String key);
  Future<bool> remove(String key);
}

class SharedPreferencesWrapper implements KeyValueWrapper {
  SharedPreferencesWrapper(this.prefs);
  final SharedPreferences prefs;

  @override
  Future<bool> setString(String key, String value) => prefs.setString(key, value);

  @override
  String? getString(String key) => prefs.getString(key);

  @override
  Future<bool> remove(String key) => prefs.remove(key);
}
