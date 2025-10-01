import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppEnv {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;
  static String get catalogBaseUrl => dotenv.env['CATALOG_BASE_URL']!;
  // Queria por outro endpoint pra pegar o catalog, mas n consegui... infelizment... e eu só tenho hoje ;(
  static String get externalMockapiBaseUrl => dotenv.env['EXTERNAL_MOCKAPI_BASE_URL']!;
}
