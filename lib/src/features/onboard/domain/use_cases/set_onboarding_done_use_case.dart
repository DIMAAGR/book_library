import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:dartz/dartz.dart';

abstract class SetOnboardingDoneUseCase {
  const SetOnboardingDoneUseCase();
  Future<Either<Failure, Unit>> call(bool value);
}

class SetOnboardingDoneUseCaseImpl implements SetOnboardingDoneUseCase {
  const SetOnboardingDoneUseCaseImpl(this.repository);
  final OnboardingRepository repository;

  @override
  Future<Either<Failure, Unit>> call(bool value) => repository.setDone(value);
}
