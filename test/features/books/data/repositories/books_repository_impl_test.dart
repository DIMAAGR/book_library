import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/data/repositories/books_repository_impl.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockBooksRemoteDataSource remote;
  late BooksRepositoryImpl repo;

  setUp(() {
    remote = MockBooksRemoteDataSource();
    repo = BooksRepositoryImpl(remote);
  });

  final raw = [
    {
      'id': '1',
      'title': 'The Lean Startup',
      'author': 'Eric Ries',
      'published': '2011-09-13',
      'publisher': 'Crown Business',
    },
    {
      'id': '2',
      'title': 'De Zero a Um',
      'author': 'Peter Thiel',
      'published': '2014-09-16',
      'publisher': 'Objetiva',
    },
  ];

  test('getAll mapeia para entidades', () async {
    when(remote.fetchBooks()).thenAnswer((_) async => raw);

    final res = await repo.getAll();
    expect(res.isRight(), true);
    res.fold((_) {}, (list) {
      expect(list, isA<List<BookEntity>>());
      expect(list.length, 2);
      expect(list.first.title, 'The Lean Startup');
    });
  });

  test('searchByTitle filtra por título case-insensitive', () async {
    when(remote.fetchBooks()).thenAnswer((_) async => raw);

    final res = await repo.searchByTitle('zero');
    expect(res.isRight(), true);
    res.fold((_) {}, (list) {
      expect(list.length, 1);
      expect(list.first.title, 'De Zero a Um');
    });
  });

  test('getAll retorna Left em erro do datasource', () async {
    when(remote.fetchBooks()).thenThrow(Exception('boom'));
    final res = await repo.getAll();
    expect(res.isLeft(), true);
    res.fold((f) => expect(f, isA<NetworkFailure>()), (_) {});
  });

  test('searchByTitle retorna Left em erro do datasource', () async {
    when(remote.fetchBooks()).thenThrow(Exception('boom'));
    final res = await repo.searchByTitle('x');
    expect(res.isLeft(), true);
    res.fold((f) => expect(f, isA<NetworkFailure>()), (_) {});
  });
}
