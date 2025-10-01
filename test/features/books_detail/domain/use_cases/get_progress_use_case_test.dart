import 'package:book_library/src/features/books_details/domain/use_cases/get_progress_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReadingRepository repo;

  setUp(() {
    repo = MockReadingRepository();
  });

  group('GetProgressUseCase', () {
    test('delegates para repo.getProgress', () async {
      when(repo.getProgress('id')).thenAnswer((_) async => const Right(35));
      final uc = GetProgressUseCaseImpl(repo);
      final res = await uc('id');
      expect(res, const Right(35));
      verify(repo.getProgress('id')).called(1);
    });
  });
}
