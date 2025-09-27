import 'package:book_library/src/core/app/main_app.dart';
import 'package:book_library/src/core/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.I;

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  await dotenv.load(fileName: '.env');
  await setupInjector();

  runApp(const MainApp());
}
