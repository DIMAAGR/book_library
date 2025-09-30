import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/data/repositories/reading_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReadingLocalDataSource ds;
  late ReadingRepositoryImpl repo;

  setUp(() {
    ds = MockReadingLocalDataSource();
    repo = ReadingRepositoryImpl(ds);
  });

  group('ReadingRepositoryImpl', () {
    test('isReading -> Right(bool) quando datasource ok', () async {
      when(ds.isReading('a')).thenAnswer((_) async => true);
      final res = await repo.isReading('a');
      expect(res, const Right(true));
    });

    test('isReading -> Left(StorageFailure) quando datasource lança', () async {
      when(ds.isReading('x')).thenThrow(Exception('boom'));
      final res = await repo.isReading('x');
      expect(res.isLeft(), true);
      res.fold((l) => expect(l, isA<StorageFailure>()), (_) => fail('esperava Left'));
    });

    test('toggleReading -> Right(bool)', () async {
      when(ds.toggleReading('b')).thenAnswer((_) async => false);
      final r = await repo.toggleReading('b');
      expect(r, const Right(false));
    });

    test('getProgress -> Right(int)', () async {
      when(ds.getProgress('c')).thenAnswer((_) async => 77);
      final r = await repo.getProgress('c');
      expect(r, const Right(77));
    });

    test('setProgress -> Right(unit)', () async {
      when(ds.setProgress('d', 45)).thenAnswer((_) async => {});
      final r = await repo.setProgress('d', 45);
      expect(r, const Right(unit));
    });
  });
}
