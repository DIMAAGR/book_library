import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/core/theme/app_theme_controller.dart';
import 'package:book_library/src/features/launcher/presentation/view_model/launcher_view_model.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source_impl.dart';
import 'package:book_library/src/features/onboard/data/repositories/onboard_repository_impl.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/get_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/set_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/presentation/services/onboard_content_provider.dart';
import 'package:book_library/src/features/onboard/presentation/view_model/onboard_view_model.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjector() async {
  getIt.registerLazySingleton<KeyValueWrapper>(() => SharedPreferencesWrapper(getIt()));
  getIt.registerSingletonAsync<AppThemeController>(() => AppThemeController.init(getIt()));

  /// -----------Infrastructure--------------
  getIt.registerLazySingleton<OnboardingRepository>(() => OnboardingRepositoryImpl(getIt()));

  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(getIt()),
  );

  /// -------------Onboard-------------------
  getIt.registerLazySingleton<OnboardContentProvider>(() => OnboardContentStatic());
  getIt.registerFactory<OnboardViewModel>(() => OnboardViewModel(getIt(), getIt()));

  /// --------------Launcher-----------------
  getIt.registerFactory<LauncherViewModel>(() => LauncherViewModel(getIt()));

  /// --------------Use Cases-----------------
  getIt.registerLazySingleton<GetOnboardingDoneUseCase>(
    () => GetOnboardingDoneUseCaseImpl(getIt()),
  );
  getIt.registerLazySingleton<SetOnboardingDoneUseCase>(
    () => SetOnboardingDoneUseCaseImpl(getIt()),
  );

  await getIt.allReady();
}
