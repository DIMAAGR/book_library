import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/onboard/data/repositories/onboard_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockOnboardingLocalDataSource mockLocal;
  late OnboardingRepositoryImpl repo;

  setUp(() {
    mockLocal = MockOnboardingLocalDataSource();
    repo = OnboardingRepositoryImpl(mockLocal);
  });

  test('isDone retorna Right(true) quando datasource retorna true', () async {
    when(mockLocal.isDone()).thenAnswer((_) async => true);

    final result = await repo.isDone();

    expect(result, const Right(true));
    verify(mockLocal.isDone()).called(1);
  });

  test('isDone retorna Left(StorageFailure) quando datasource lança exceção', () async {
    when(mockLocal.isDone()).thenThrow(Exception('boom'));

    final result = await repo.isDone();

    expect(result, isA<Left>());
    expect(result.fold((l) => l, (_) => null), isA<StorageFailure>());
  });

  test('setDone retorna Right(unit) quando datasource não lança', () async {
    when(mockLocal.setDone(true)).thenAnswer((_) async {});

    final result = await repo.setDone(true);

    expect(result, const Right(unit));
    verify(mockLocal.setDone(true)).called(1);
  });

  test('setDone retorna Left(StorageFailure) quando datasource lança exceção', () async {
    when(mockLocal.setDone(true)).thenThrow(Exception('fail'));

    final result = await repo.setDone(true);

    expect(result.fold((l) => l, (_) => null), isA<StorageFailure>());
  });
}
