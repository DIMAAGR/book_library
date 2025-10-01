import 'package:book_library/src/features/books_details/domain/use_cases/toggle_reading_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockReadingRepository repo;

  setUp(() {
    repo = MockReadingRepository();
  });

  group('ToggleReadingUseCase', () {
    test('delegates para repo.toggleReading', () async {
      when(repo.toggleReading('id')).thenAnswer((_) async => const Right(false));
      final uc = ToggleReadingUseCaseImpl(repo);
      final res = await uc('id');
      expect(res, const Right(false));
      verify(repo.toggleReading('id')).called(1);
    });
  });
}
