import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/data/repositories/categories_repository_impl.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockCategoriesFakeDataSource ds;
  late CategoriesRepositoryImpl repo;

  setUp(() {
    ds = MockCategoriesFakeDataSource();
    repo = CategoriesRepositoryImpl(ds);
  });

  test('getAll retorna entidades ao sucesso', () async {
    when(ds.fetchCategories()).thenAnswer(
      (_) async => [
        {'id': '1', 'name': 'Romance'},
        {'id': '2', 'name': 'Fantasy'},
      ],
    );

    final res = await repo.getAll();
    expect(res.isRight(), true);
    res.fold((_) {}, (list) {
      expect(list, isA<List<CategoryEntity>>());
      expect(list.first.name, 'Romance');
    });
  });

  test('getAll retorna FakeFailure em exceção do datasource', () async {
    when(ds.fetchCategories()).thenThrow(Exception('x'));
    final res = await repo.getAll();
    expect(res.isLeft(), true);
    res.fold((f) => expect(f, isA<FakeFailure>()), (_) {});
  });
}
