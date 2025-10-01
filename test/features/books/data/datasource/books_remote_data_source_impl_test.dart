import 'package:book_library/src/features/books/data/datasources/books_remote_data_source/books_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockDio dio;
  late BooksRemoteDataSourceImpl ds;

  setUp(() {
    dio = MockDio();
    ds = BooksRemoteDataSourceImpl(dio);
  });

  test('fetchBooks retorna lista de maps', () async {
    final data = [
      {'id': '1', 'title': 'A', 'author': 'X', 'published': '2020-01-01', 'publisher': 'P'},
    ];
    when(dio.get(any)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/'),
        data: data,
        statusCode: 200,
      ),
    );

    final res = await ds.fetchBooks();
    expect(res, isA<List<Map<String, dynamic>>>());
    expect(res.length, 1);
    expect(res.first['title'], 'A');
  });

  test('fetchBooks propaga exceção do dio', () async {
    when(dio.get(any)).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));
    expect(() => ds.fetchBooks(), throwsA(isA<DioException>()));
  });
}
