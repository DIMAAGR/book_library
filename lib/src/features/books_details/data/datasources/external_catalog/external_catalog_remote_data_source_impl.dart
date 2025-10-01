import 'package:book_library/src/core/constants/api_paths.dart';
import 'package:book_library/src/features/books_details/data/datasources/external_catalog/external_catalog_remote_data_source.dart';
import 'package:dio/dio.dart';

class ExternalCatalogRemoteDataSourceImpl implements ExternalCatalogRemoteDataSource {
  ExternalCatalogRemoteDataSourceImpl(this.dio);
  final Dio dio;

  @override
  Future<Map<String, dynamic>> findByTitleAuthor({
    required String title,
    required String author,
  }) async {
    final q = 'intitle:${title.trim()}';
    final params = <String, dynamic>{'q': q, 'maxResults': 10};

    final res = await dio.get(ApiPaths.volumes, queryParameters: params);
    return res.data as Map<String, dynamic>;
  }
}
