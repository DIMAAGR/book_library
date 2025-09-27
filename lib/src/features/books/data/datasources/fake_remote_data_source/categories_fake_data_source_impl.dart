import 'package:book_library/src/features/books/data/datasources/fake_remote_data_source/categories_fake_data_source.dart';

class CategoriesFakeDataSourceImpl implements CategoriesFakeDataSource {
  @override
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    return [
      {'id': '1', 'name': 'Romance'},
      {'id': '2', 'name': 'Fantasy'},
      {'id': '3', 'name': 'Sci-Fi'},
      {'id': '4', 'name': 'Business'},
      {'id': '5', 'name': 'Technology'},
    ];
  }
}
