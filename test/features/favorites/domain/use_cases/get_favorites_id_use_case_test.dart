import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/get_favorites_id_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late GetFavoritesIdsUseCaseImpl usecase;
  late MockFavoritesRepository mockRepo;

  setUp(() {
    mockRepo = MockFavoritesRepository();
    usecase = GetFavoritesIdsUseCaseImpl(mockRepo);
  });

  test('deve retornar Right<Set<String>> do repository', () async {
    when(mockRepo.getAllIds()).thenAnswer((_) async => const Right({'1', '2'}));

    final result = await usecase();
    expect(result.isRight(), true);
    expect(result.getOrElse(() => {}), {'1', '2'});

    verify(mockRepo.getAllIds()).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('deve propagar Left<Failure> do repository', () async {
    final failure = const StorageFailure('boom');
    when(mockRepo.getAllIds()).thenAnswer((_) async => Left(failure));

    final result = await usecase();
    expect(result.isLeft(), true);
    result.fold((f) => expect(f, same(failure)), (_) => fail('esperava Left'));
  });
}
