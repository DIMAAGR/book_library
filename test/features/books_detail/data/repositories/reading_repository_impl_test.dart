import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/data/repositories/reading_repository_impl.dart';
import 'package:book_library/src/features/books_details/domain/repositories/reading_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReadingLocalDataSource ds;
  late ReadingRepository repo;

  /// “Banco de dados” em memória simulando o JSON do storage.
  ///
  /// Formato esperado por este repo:
  /// {
  ///   "<bookId>": { "isReading": bool, "progress": int },
  ///   ...
  /// }
  late Map<String, dynamic> mem;

  setUp(() {
    ds = MockReadingLocalDataSource();
    repo = ReadingRepositoryImpl(ds);
    mem = <String, dynamic>{};

    when(ds.readAll()).thenAnswer((_) async => Map<String, dynamic>.from(mem));

    when(ds.writeAll(any)).thenAnswer((inv) async {
      final arg = inv.positionalArguments[0] as Map<String, dynamic>;
      mem = Map<String, dynamic>.from(arg);
    });
  });

  group('ReadingRepositoryImpl', () {
    test('isReading: retorna false quando id não existe', () async {
      final r = await repo.isReading('id-1');
      expect(r, const Right(false));
      verify(ds.readAll()).called(1);
      verifyNever(ds.writeAll(any));
    });

    test('isReading: retorna true quando isReading=true no mapa', () async {
      mem['book-1'] = {'isReading': true, 'progress': 40};

      final r = await repo.isReading('book-1');
      expect(r, const Right(true));
      verify(ds.readAll()).called(1);
      verifyNever(ds.writeAll(any));
    });

    test('toggleReading: alterna de false→true e depois true→false', () async {
      final r1 = await repo.toggleReading('b');
      expect(r1, const Right(true));
      expect(mem['b'], isA<Map<String, dynamic>>());

      expect((mem['b'] as Map<String, dynamic>)['isReading'], true);

      final check = await repo.isReading('b');
      expect(check, const Right(true));

      final r2 = await repo.toggleReading('b');
      expect(r2, const Right(false));
      expect((mem['b'] as Map<String, dynamic>)['isReading'], false);
    });

    test('getProgress: retorna 0 quando não existe', () async {
      final r = await repo.getProgress('x');
      expect(r, const Right(0));
      verify(ds.readAll()).called(1);
    });

    test('getProgress: retorna valor existente (clamp negativo → 0)', () async {
      mem['x'] = {'progress': -10};
      final r = await repo.getProgress('x');
      expect(r, const Right(0));
    });

    test('getProgress: clamp > 100 → 100', () async {
      mem['x'] = {'progress': 120};
      final r = await repo.getProgress('x');
      expect(r, const Right(100));
    });

    test('setProgress: grava valor clampado (negativo vira 0)', () async {
      final r = await repo.setProgress('b', -5);
      expect(r, const Right(unit));
      expect(mem['b'], isA<Map>());
      expect((mem['b'] as Map<String, dynamic>)['progress'], 0);
    });

    test('setProgress: grava valor clampado (>100 vira 100)', () async {
      final r = await repo.setProgress('b', 250);
      expect(r, const Right(unit));
      expect((mem['b'] as Map<String, dynamic>)['progress'], 100);
    });

    test('isReading: Left(StorageFailure) quando readAll lança', () async {
      when(ds.readAll()).thenThrow(Exception('boom'));

      final r = await repo.isReading('a');
      expect(r.isLeft(), true);

      r.fold((l) => expect(l, isA<StorageFailure>()), (_) => fail('deveria ter retornado Left'));
    });

    test('toggleReading: Left(StorageFailure) quando readAll lança', () async {
      when(ds.readAll()).thenThrow(Exception('boom'));

      final r = await repo.toggleReading('a');
      expect(r.isLeft(), true);
    });

    test('getProgress: Left(StorageFailure) quando readAll lança', () async {
      when(ds.readAll()).thenThrow(Exception('boom'));

      final r = await repo.getProgress('a');
      expect(r.isLeft(), true);
    });

    test('setProgress: Left(StorageFailure) quando writeAll lança', () async {
      when(ds.writeAll(any)).thenThrow(Exception('boom'));

      final r = await repo.setProgress('a', 10);
      expect(r.isLeft(), true);
    });
  });
}
