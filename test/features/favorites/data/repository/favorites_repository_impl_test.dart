import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late FavoritesRepositoryImpl repo;
  late MockFavoritesLocalDataSource local;

  setUp(() {
    local = MockFavoritesLocalDataSource();
    repo = FavoritesRepositoryImpl(local);
  });

  test('getAllIds: Right(set) quando local ok', () async {
    when(local.readIds()).thenAnswer((_) async => {'1', '2'});

    final either = await repo.getAllIds();
    expect(either.isRight(), true);
    expect(either.getOrElse(() => {}), {'1', '2'});
  });

  test('getAllIds: Left(StorageFailure) quando local lança', () async {
    when(local.readIds()).thenThrow(Exception('boom'));

    final either = await repo.getAllIds();
    expect(either.isLeft(), true);
    either.fold((f) => expect(f, isA<StorageFailure>()), (_) => fail('esperava Left'));
  });

  test('toggle: adiciona novo id quando não existe e persiste', () async {
    when(local.readIds()).thenAnswer((_) async => {'a'});
    when(local.writeIds(any)).thenAnswer((_) async {});

    final either = await repo.toggle('b');
    expect(either.isRight(), true);
    expect(either.getOrElse(() => {}), {'a', 'b'});

    verify(local.writeIds({'a', 'b'})).called(1);
  });

  test('toggle: remove id quando existe e persiste', () async {
    when(local.readIds()).thenAnswer((_) async => {'a', 'b'});
    when(local.writeIds(any)).thenAnswer((_) async {});

    final either = await repo.toggle('a');
    expect(either.isRight(), true);
    expect(either.getOrElse(() => {}), {'b'});

    verify(local.writeIds({'b'})).called(1);
  });
}
