import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetOnboardingDoneUseCase {
  const GetOnboardingDoneUseCase();
  Future<Either<Failure, bool>> call();
}

class GetOnboardingDoneUseCaseImpl implements GetOnboardingDoneUseCase {
  const GetOnboardingDoneUseCaseImpl(this.repository);
  final OnboardingRepository repository;

  @override
  Future<Either<Failure, bool>> call() => repository.isDone();
}
