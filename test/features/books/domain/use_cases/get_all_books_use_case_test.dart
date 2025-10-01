import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockBooksRepository repo;
  late GetAllBooksUseCase usecase;

  setUp(() {
    repo = MockBooksRepository();
    usecase = GetAllBooksUseCaseImpl(repo);
  });

  test('delegates to repository.getAll', () async {
    when(repo.getAll()).thenAnswer((_) async => const Right(<BookEntity>[]));
    final res = await usecase();
    expect(res.isRight(), true);
    verify(repo.getAll()).called(1);
  });

  test('propaga Left do repository', () async {
    when(repo.getAll()).thenAnswer((_) async => const Left(NetworkFailure('e')));
    final res = await usecase();
    expect(res.isLeft(), true);
  });
}
