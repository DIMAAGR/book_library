import 'package:book_library/src/core/constants/app_env.dart';
import 'package:book_library/src/core/network/dio_factory.dart';
import 'package:book_library/src/core/services/cache/cache.dart';
import 'package:book_library/src/core/services/cache/lru_cache.dart';
import 'package:book_library/src/core/services/coalescing/inflight_coalescer.dart';
import 'package:book_library/src/core/services/coalescing/map_inflight_coalescer.dart';
import 'package:book_library/src/core/services/concurrency/concurrency_limiter.dart';
import 'package:book_library/src/core/services/concurrency/semaphore_limiter.dart';
import 'package:book_library/src/core/services/key/canonical_key_strategy.dart';
import 'package:book_library/src/core/services/key/default_canonical_key.dart';
import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/core/theme/app_theme_controller.dart';
import 'package:book_library/src/features/books/data/datasources/books_remote_data_source/books_remote_data_source.dart';
import 'package:book_library/src/features/books/data/datasources/books_remote_data_source/books_remote_data_source_impl.dart';
import 'package:book_library/src/features/books/data/datasources/fake_remote_data_source/categories_fake_data_source.dart';
import 'package:book_library/src/features/books/data/datasources/fake_remote_data_source/categories_fake_data_source_impl.dart';
import 'package:book_library/src/features/books/data/repositories/books_repository_impl.dart';
import 'package:book_library/src/features/books/data/repositories/categories_repository_impl.dart';
import 'package:book_library/src/features/books/domain/repositories/books_repository.dart';
import 'package:book_library/src/features/books/domain/repositories/categories_repository.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_book_by_title_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/data/datasources/external_catalog_remote_data_source.dart';
import 'package:book_library/src/features/books_details/data/datasources/external_catalog_remote_data_source_impl.dart';
import 'package:book_library/src/features/books_details/data/repositories/books_details_repository_impl.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/domain/repositories/book_details_repository.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_book_details_use_case.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_view_model.dart';
import 'package:book_library/src/features/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:book_library/src/features/favorites/data/datasource/favorites_local_data_source_impl.dart';
import 'package:book_library/src/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:book_library/src/features/favorites/domain/repository/favorites_repository.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/is_favorite_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_view_model.dart';
import 'package:book_library/src/features/launcher/presentation/view_model/launcher_view_model.dart';
import 'package:book_library/src/features/library/presentation/view_model/library_view_model.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source_impl.dart';
import 'package:book_library/src/features/onboard/data/repositories/onboard_repository_impl.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/get_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/set_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/presentation/services/onboard_content_provider.dart';
import 'package:book_library/src/features/onboard/presentation/view_model/onboard_view_model.dart';
import 'package:book_library/src/features/search/presentation/view_model/search_view_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjector() async {
  getIt.registerLazySingleton<KeyValueWrapper>(() => SharedPreferencesWrapper(getIt()));
  getIt.registerSingletonAsync<AppThemeController>(() => AppThemeController.init(getIt()));

  /// -----------Infrastructure--------------
  getIt.registerLazySingleton<OnboardingRepository>(() => OnboardingRepositoryImpl(getIt()));
  getIt.registerLazySingleton<BooksRepository>(() => BooksRepositoryImpl(getIt()));
  getIt.registerLazySingleton<CategoriesRepository>(() => CategoriesRepositoryImpl(getIt()));
  getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(getIt()));

  getIt.registerLazySingleton<Dio>(
    () => DioFactory.create(baseUrl: AppEnv.apiBaseUrl),
    instanceName: 'api',
  );
  getIt.registerLazySingleton<Dio>(
    () => DioFactory.create(baseUrl: AppEnv.catalogBaseUrl),
    instanceName: 'catalog',
  );

  getIt.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<CategoriesFakeDataSource>(() => CategoriesFakeDataSourceImpl());

  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<BooksRemoteDataSource>(
    () => BooksRemoteDataSourceImpl(getIt<Dio>(instanceName: 'api')),
  );

  getIt.registerLazySingleton<ExternalCatalogRemoteDataSource>(
    () => ExternalCatalogRemoteDataSourceImpl(getIt<Dio>(instanceName: 'catalog')),
  );
  getIt.registerLazySingleton<ExternalBookInfoRepository>(
    () => ExternalBookInfoRepositoryImpl(getIt()),
  );

  /// -------------Onboard-------------------
  getIt.registerLazySingleton<OnboardContentProvider>(() => OnboardContentStatic());
  getIt.registerLazySingleton<OnboardViewModel>(() => OnboardViewModel(getIt(), getIt()));

  /// --------------Launcher-----------------
  getIt.registerLazySingleton<LauncherViewModel>(() => LauncherViewModel(getIt()));

  /// ----------------Home-------------------
  getIt.registerLazySingleton<HomeViewModel>(() => HomeViewModel(getIt(), getIt(), getIt()));

  /// ----------------Library----------------
  getIt.registerFactory<LibraryViewModel>(() => LibraryViewModel(getIt(), getIt(), getIt()));

  /// ----------------Search-----------------
  getIt.registerFactory<SearchViewModel>(
    () => SearchViewModel(getIt(), getIt(), getIt(), getIt(), getIt()),
  );

  /// --------------Explorer-----------------
  getIt.registerFactory<ExploreViewModel>(
    () => ExploreViewModel(getIt(), getIt(), getIt(), getIt()),
  );

  /// --------------Favorites-----------------
  getIt.registerFactory<FavoritesViewModel>(
    () => FavoritesViewModel(getIt(), getIt(), getIt(), getIt()),
  );

  /// --------------Use Cases----------------
  getIt.registerLazySingleton<GetAllBooksUseCase>(() => GetAllBooksUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetBookDetailsUseCase>(() => GetBookDetailsUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetFavoritesIdsUseCase>(() => GetFavoritesIdsUseCaseImpl(getIt()));
  getIt.registerLazySingleton<ToggleFavoriteUseCase>(() => ToggleFavoriteUseCaseImpl(getIt()));
  getIt.registerLazySingleton<IsFavoriteUseCase>(() => IsFavoriteUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetBookByTitleUseCase>(() => GetBookByTitleUseCaseImpl(getIt()));

  getIt.registerLazySingleton<GetOnboardingDoneUseCase>(
    () => GetOnboardingDoneUseCaseImpl(getIt()),
  );

  getIt.registerLazySingleton<SetOnboardingDoneUseCase>(
    () => SetOnboardingDoneUseCaseImpl(getIt()),
  );

  // -------------- CACHE -------------------
  getIt.registerLazySingleton<CanonicalKeyStrategy>(() => DefaultCanonicalKey());
  getIt.registerLazySingleton<Cache<String, ExternalBookInfoEntity?>>(() => LruCache(256));
  getIt.registerLazySingleton<ConcurrencyLimiter>(() => SemaphoreLimiter(6));
  getIt.registerLazySingleton<InflightCoalescer<String, ExternalBookInfoEntity?>>(
    () => MapInflightCoalescer(),
  );

  getIt.registerLazySingleton<ExternalBookInfoResolver>(
    () => ExternalBookInfoResolver(
      usecase: getIt(),
      cache: getIt(),
      limiter: getIt(),
      coalescer: getIt(),
      keyOf: getIt(),
    ),
  );

  await getIt.allReady();
}
