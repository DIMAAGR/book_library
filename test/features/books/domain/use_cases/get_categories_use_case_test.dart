import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books/domain/usecases/get_categories_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockCategoriesRepository repo;
  late GetCategoriesUseCase usecase;

  setUp(() {
    repo = MockCategoriesRepository();
    usecase = GetCategoriesUseCaseImpl(repo);
  });

  test('delegates to repository.getAll', () async {
    when(repo.getAll()).thenAnswer((_) async => const Right(<CategoryEntity>[]));
    final res = await usecase();
    expect(res.isRight(), true);
    verify(repo.getAll()).called(1);
  });

  test('propaga Left do repository', () async {
    when(repo.getAll()).thenAnswer((_) async => const Left(FakeFailure('x')));
    final res = await usecase();
    expect(res.isLeft(), true);
  });
}
