import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppEnv {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;

  static String get catalogBaseUrl => dotenv.env['CATALOG_BASE_URL']!;
}
