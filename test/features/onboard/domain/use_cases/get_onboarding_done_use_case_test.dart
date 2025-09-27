import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/get_onboarding_done_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockOnboardingRepository mockRepo;
  late GetOnboardingDoneUseCase useCase;

  setUp(() {
    mockRepo = MockOnboardingRepository();
    useCase = GetOnboardingDoneUseCaseImpl(mockRepo);
  });

  test('retorna Right(true) quando repo retorna true', () async {
    when(mockRepo.isDone()).thenAnswer((_) async => const Right(true));

    final result = await useCase();

    expect(result, const Right(true));
    verify(mockRepo.isDone()).called(1);
  });

  test('retorna Left(StorageFailure) quando repo falha', () async {
    when(mockRepo.isDone()).thenAnswer((_) async => const Left(StorageFailure('fail')));

    final result = await useCase();

    expect(result.isLeft(), true);
    expect(result.fold((l) => l, (_) => null), isA<StorageFailure>());
  });

  test('chama repo.isDone exatamente 1x e sem mais interações', () async {
    when(mockRepo.isDone()).thenAnswer((_) async => const Right(true));

    await useCase();

    verify(mockRepo.isDone()).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
