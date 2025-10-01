import 'package:book_library/src/core/storage/schema/storage_schema.dart';
import 'package:book_library/src/core/theme/app_theme.dart';
import 'package:book_library/src/core/theme/app_theme_mode_enum.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
  AppThemeController._(this.prefs, this.key, String? raw) {
    if (raw != null) {
      mode.value = AppThemeMode.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => AppThemeMode.light,
      );
    }
  }
  final SharedPreferences prefs;
  final String key;
  final ValueNotifier<AppThemeMode> mode = ValueNotifier(AppThemeMode.light);

  static Future<AppThemeController> init(SharedPreferences prefs) async {
    final key = StorageSchema.themeKey;
    return AppThemeController._(prefs, key, prefs.getString(key));
  }

  ThemeData get theme => AppTheme.resolve(mode.value);

  Future<void> set(AppThemeMode newMode) async {
    if (mode.value == newMode) return;
    mode.value = newMode;
    await prefs.setString(key, newMode.name);
  }
}
