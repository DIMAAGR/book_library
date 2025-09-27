import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_book_by_title_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockBooksRepository repo;
  late GetBookByTitleUseCase usecase;

  setUp(() {
    repo = MockBooksRepository();
    usecase = GetBookByTitleUseCaseImpl(repo);
  });

  test('delegates to repository.searchByTitle', () async {
    when(repo.searchByTitle('lean')).thenAnswer((_) async => const Right(<BookEntity>[]));
    final res = await usecase('lean');
    expect(res.isRight(), true);
    verify(repo.searchByTitle('lean')).called(1);
  });

  test('propaga Left do repository', () async {
    when(repo.searchByTitle(any)).thenAnswer((_) async => const Left(NetworkFailure('e')));
    final res = await usecase('x');
    expect(res.isLeft(), true);
  });
}
