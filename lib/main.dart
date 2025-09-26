import 'package:book_library/src/core/app/main_app.dart';
import 'package:book_library/src/core/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  GetIt.I.registerLazySingleton<SharedPreferences>(() => prefs);

  await setupInjector();
  runApp(MainApp());
}
