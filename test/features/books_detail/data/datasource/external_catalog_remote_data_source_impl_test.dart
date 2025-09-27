import 'package:book_library/src/core/constants/api_paths.dart';
import 'package:book_library/src/features/books_details/data/datasources/external_catalog_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late ExternalCatalogRemoteDataSourceImpl ds;

  setUp(() {
    mockDio = MockDio();
    ds = ExternalCatalogRemoteDataSourceImpl(mockDio);
  });

  test('findByTitleAuthor: monta query e retorna json', () async {
    const title = 'Empreendedorismo Inovador';
    const author = 'Nei Grando, Outro Nome';

    final fakeResponse = {
      'kind': 'books#volumes',
      'items': [
        {
          'volumeInfo': {'title': title},
        },
      ],
    };

    when(mockDio.get(ApiPaths.volumes, queryParameters: anyNamed('queryParameters'))).thenAnswer(
      (_) async => Response(
        data: fakeResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiPaths.volumes),
      ),
    );

    final result = await ds.findByTitleAuthor(title: title, author: author);

    final captured =
        verify(
              mockDio.get(ApiPaths.volumes, queryParameters: captureAnyNamed('queryParameters')),
            ).captured.first
            as Map<String, dynamic>;

    expect(captured['q'], 'intitle:Empreendedorismo Inovador inauthor:Nei Grando');
    expect(captured['maxResults'], 1);
    expect(result['kind'], 'books#volumes');
  });
}
