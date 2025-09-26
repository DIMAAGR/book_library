import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/core/theme/app_theme_controller.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjector() async {
  getIt.registerLazySingleton<KeyValueWrapper>(() => SharedPreferencesWrapper(getIt()));
  getIt.registerSingletonAsync<AppThemeController>(() => AppThemeController.init(getIt()));
}
