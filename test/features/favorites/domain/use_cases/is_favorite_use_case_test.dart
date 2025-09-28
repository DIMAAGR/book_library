import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/is_favorite_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late IsFavoriteUseCaseImpl usecase;
  late MockFavoritesRepository mockRepo;

  setUp(() {
    mockRepo = MockFavoritesRepository();
    usecase = IsFavoriteUseCaseImpl(mockRepo);
  });

  test('deve delegar para repo.isFavorite(id) e retornar Right<bool>', () async {
    when(mockRepo.isFavorite('abc')).thenAnswer((_) async => const Right(true));

    final result = await usecase('abc');
    expect(result.isRight(), true);
    expect(result.getOrElse(() => false), true);

    verify(mockRepo.isFavorite('abc')).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('deve propagar Left<Failure> do repository', () async {
    final failure = const StorageFailure('err');
    when(mockRepo.isFavorite('xyz')).thenAnswer((_) async => Left(failure));

    final result = await usecase('xyz');
    expect(result.isLeft(), true);
    result.fold((f) => expect(f, same(failure)), (_) => fail('esperava Left'));
  });
}
