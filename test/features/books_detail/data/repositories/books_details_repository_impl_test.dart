import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/data/repositories/books_details_repository_impl.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockExternalCatalogRemoteDataSource mockRemote;
  late ExternalBookInfoRepositoryImpl repo;

  setUp(() {
    mockRemote = MockExternalCatalogRemoteDataSource();
    repo = ExternalBookInfoRepositoryImpl(mockRemote);
  });

  test('resolveByTitleAuthor: Right(entity) quando JSON válido', () async {
    when(
      mockRemote.findByTitleAuthor(title: anyNamed('title'), author: anyNamed('author')),
    ).thenAnswer(
      (_) async => {
        'items': [
          {
            'volumeInfo': {
              'title': 'Gestão de qualidade em saúde',
              'description': 'desc',
              'imageLinks': {'thumbnail': 'http://img'},
              'industryIdentifiers': [
                {'type': 'ISBN_13', 'identifier': '9786553811072'},
              ],
            },
          },
        ],
      },
    );

    final either = await repo.resolveByTitleAuthor(title: 'x', author: 'y');

    expect(either.isRight(), true);
    final entity = (either as Right<Failure, ExternalBookInfoEntity?>).value;
    expect(entity?.title, 'Gestão de qualidade em saúde');
    expect(entity?.description, 'desc');
    expect(entity?.coverUrl, 'http://img');
    expect(entity?.isbn13, '9786553811072');
  });

  test('resolveByTitleAuthor: Left(NetworkFailure) quando remote lança', () async {
    when(
      mockRemote.findByTitleAuthor(title: anyNamed('title'), author: anyNamed('author')),
    ).thenThrow(Exception('boom'));

    final either = await repo.resolveByTitleAuthor(title: 't', author: 'a');

    expect(either.isLeft(), true);
    final failure = (either as Left<Failure, dynamic>).value;
    expect(failure, isA<NetworkFailure>());
  });
}
