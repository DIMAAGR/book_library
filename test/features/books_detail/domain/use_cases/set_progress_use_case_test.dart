import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/set_progress_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReadingRepository repo;

  setUp(() {
    repo = MockReadingRepository();
  });

  group('SetProgressUseCase', () {
    test('delegates para repo.setProgress', () async {
      when(repo.setProgress('id', 80)).thenAnswer((_) async => const Right(unit));
      final uc = SetProgressUseCaseImpl(repo);
      final res = await uc('id', 80);
      expect(res, const Right(unit));
      verify(repo.setProgress('id', 80)).called(1);
    });
    test('propaga Left(StorageFailure) do repo', () async {
      when(repo.setProgress('id', 10)).thenAnswer((_) async => const Left(StorageFailure('err')));
      final uc = SetProgressUseCaseImpl(repo);
      final res = await uc('id', 10);
      expect(res.isLeft(), true);
    });
  });
}
