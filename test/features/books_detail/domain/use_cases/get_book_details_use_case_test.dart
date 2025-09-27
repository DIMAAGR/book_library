import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_book_details_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockExternalBookInfoRepository mockRepo;
  late GetBookDetailsUseCase usecase;

  setUp(() {
    mockRepo = MockExternalBookInfoRepository();
    usecase = GetBookDetailsUseCaseImpl(mockRepo);
  });

  test('delegates para o repository', () async {
    const entity = ExternalBookInfoEntity(
      title: 't',
      description: 'd',
      coverUrl: 'u',
      isbn13: '978',
    );

    when(
      mockRepo.resolveByTitleAuthor(title: 'A', author: 'B'),
    ).thenAnswer((_) async => const Right(entity));

    final res = await usecase(title: 'A', author: 'B');

    expect(res.isRight(), true);
    verify(mockRepo.resolveByTitleAuthor(title: 'A', author: 'B')).called(1);
  });
}
