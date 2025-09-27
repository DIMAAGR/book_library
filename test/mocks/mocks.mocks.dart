import 'package:book_library/src/core/storage/wrapper/shared_preferences_wrapper.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/get_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/set_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/presentation/services/onboard_content_provider.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  KeyValueWrapper,
  OnboardingLocalDataSource,
  OnboardingRepository,
  OnboardContentProvider,
  SetOnboardingDoneUseCase,
  GetOnboardingDoneUseCase,
])
void main() {}
