import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late ToggleFavoriteUseCaseImpl usecase;
  late MockFavoritesRepository mockRepo;

  setUp(() {
    mockRepo = MockFavoritesRepository();
    usecase = ToggleFavoriteUseCaseImpl(mockRepo);
  });

  test('deve delegar para repo.toggle(id) e retornar Right<Set<String>>', () async {
    when(mockRepo.toggle('1')).thenAnswer((_) async => const Right({'1', '2'}));

    final result = await usecase('1');
    expect(result.isRight(), true);
    expect(result.getOrElse(() => {}), {'1', '2'});

    verify(mockRepo.toggle('1')).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('deve propagar Left<Failure> do repository', () async {
    final failure = const StorageFailure('toggle fail');
    when(mockRepo.toggle('x')).thenAnswer((_) async => Left(failure));

    final result = await usecase('x');
    expect(result.isLeft(), true);
    result.fold((f) => expect(f, same(failure)), (_) => fail('esperava Left'));
  });
}
