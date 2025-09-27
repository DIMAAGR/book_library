import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/set_onboarding_done_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockOnboardingRepository mockRepo;
  late SetOnboardingDoneUseCase useCase;

  setUp(() {
    mockRepo = MockOnboardingRepository();
    useCase = SetOnboardingDoneUseCaseImpl(mockRepo);
  });

  test('retorna Right(unit) quando repo salva com sucesso', () async {
    when(mockRepo.setDone(true)).thenAnswer((_) async => const Right(unit));

    final result = await useCase(true);

    expect(result, const Right(unit));
    verify(mockRepo.setDone(true)).called(1);
  });

  test('retorna Left(StorageFailure) quando repo falha ao salvar', () async {
    when(mockRepo.setDone(false)).thenAnswer((_) async => const Left(StorageFailure('fail')));

    final result = await useCase(false);

    expect(result.isLeft(), true);
    expect(result.fold((l) => l, (_) => null), isA<StorageFailure>());
  });
  test('forward do argumento FALSE para o repo', () async {
    when(mockRepo.setDone(false)).thenAnswer((_) async => const Right(unit));

    final result = await useCase(false);

    expect(result, const Right(unit));
    verify(mockRepo.setDone(false)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('forward do argumento TRUE para o repo', () async {
    when(mockRepo.setDone(true)).thenAnswer((_) async => const Right(unit));

    final result = await useCase(true);

    expect(result, const Right(unit));
    verify(mockRepo.setDone(true)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
