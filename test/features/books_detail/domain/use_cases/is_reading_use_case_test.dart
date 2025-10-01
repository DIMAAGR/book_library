import 'package:book_library/src/features/books_details/domain/use_cases/is_reading_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReadingRepository repo;

  setUp(() {
    repo = MockReadingRepository();
  });

  group('IsReadingUseCase', () {
    test('delegates para repo.isReading e retorna Either', () async {
      when(repo.isReading('id')).thenAnswer((_) async => const Right(true));
      final uc = IsReadingUseCaseImpl(repo);
      final res = await uc('id');
      expect(res, const Right(true));
      verify(repo.isReading('id')).called(1);
    });
  });
}
