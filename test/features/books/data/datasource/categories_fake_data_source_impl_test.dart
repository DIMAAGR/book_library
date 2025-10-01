import 'package:book_library/src/features/books/data/datasources/fake_remote_data_source/categories_fake_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchCategories retorna cinco categorias padrão', () async {
    final ds = CategoriesFakeDataSourceImpl();
    final res = await ds.fetchCategories();
    expect(res.length, 5);
    expect(res.first['name'], isNotEmpty);
  });
}
