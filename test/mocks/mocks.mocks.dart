import 'package:book_library/src/core/services/cache/cache.dart';
import 'package:book_library/src/core/services/coalescing/inflight_coalescer.dart';
import 'package:book_library/src/core/services/concurrency/concurrency_limiter.dart';
import 'package:book_library/src/core/services/share/share_services.dart';
import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/features/books/data/datasources/books_remote_data_source/books_remote_data_source.dart';
import 'package:book_library/src/features/books/data/datasources/fake_remote_data_source/categories_fake_data_source.dart';
import 'package:book_library/src/features/books/domain/repositories/books_repository.dart';
import 'package:book_library/src/features/books/domain/repositories/categories_repository.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_book_by_title_use_case.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:book_library/src/features/books_details/data/datasources/external_catalog/external_catalog_remote_data_source.dart';
import 'package:book_library/src/features/books_details/data/datasources/reading/reading_local_data_source.dart';
import 'package:book_library/src/features/books_details/domain/repositories/book_details_repository.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_book_details_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_progress_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/is_reading_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/set_progress_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/toggle_reading_use_case.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/favorites/data/datasource/favorites_local_data_source.dart';
import 'package:book_library/src/features/favorites/domain/repository/favorites_repository.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/is_favorite_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/get_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/set_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/presentation/services/onboard_content_provider.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  KeyValueWrapper,
  OnboardingLocalDataSource,
  OnboardingRepository,
  OnboardContentProvider,
  SetOnboardingDoneUseCase,
  GetOnboardingDoneUseCase,
  GetAllBooksUseCase,
  GetCategoriesUseCase,
  ExternalBookInfoResolver,
  Dio,
  ExternalCatalogRemoteDataSource,
  ExternalBookInfoRepository,
  GetBookDetailsUseCase,
  Cache,
  ConcurrencyLimiter,
  InflightCoalescer,
  BooksRemoteDataSource,
  CategoriesFakeDataSource,
  BooksRepository,
  CategoriesRepository,
  FavoritesLocalDataSource,
  GetBookByTitleUseCase,
  GetFavoritesIdsUseCase,
  ToggleFavoriteUseCase,
  IsFavoriteUseCase,
  FavoritesRepository,
  ReadingLocalDataSource,
  ReadingRepository,
  ShareService,
  IsReadingUseCase,
  ToggleReadingUseCase,
  GetProgressUseCase,
  SetProgressUseCase,
])
void main() {}
