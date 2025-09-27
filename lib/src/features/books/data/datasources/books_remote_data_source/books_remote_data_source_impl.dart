import 'package:book_library/src/core/constants/api_paths.dart';
import 'package:book_library/src/features/books/data/datasources/books_remote_data_source/books_remote_data_source.dart';
import 'package:dio/dio.dart';

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  const BooksRemoteDataSourceImpl(this.dio);
  final Dio dio;

  @override
  Future<List<Map<String, dynamic>>> fetchBooks() async {
    final res = await dio.get(ApiPaths.books);
    final data = res.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
