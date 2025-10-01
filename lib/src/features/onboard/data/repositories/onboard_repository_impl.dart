import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/onboard/data/datasources/local_data_source.dart';
import 'package:book_library/src/features/onboard/domain/repository/onboard_repository.dart';
import 'package:dartz/dartz.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this.local);
  final OnboardingLocalDataSource local;

  @override
  Future<Either<Failure, bool>> isDone() async {
    try {
      final done = await local.isDone();
      return Right(done);
    } catch (e, s) {
      return Left(StorageFailure('Failed to read onboarding flag', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, Unit>> setDone(bool value) async {
    try {
      await local.setDone(value);
      return const Right(unit);
    } catch (e, s) {
      return Left(StorageFailure('Failed to write onboarding flag', cause: e, stackTrace: s));
    }
  }
}
