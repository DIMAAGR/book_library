import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/domain/repositories/book_details_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetBookDetailsUseCase {
  const GetBookDetailsUseCase();

  Future<Either<Failure, ExternalBookInfoEntity?>> call({
    required String title,
    required String author,
  });
}

class GetBookDetailsUseCaseImpl implements GetBookDetailsUseCase {
  const GetBookDetailsUseCaseImpl(this.repo);
  final ExternalBookInfoRepository repo;

  @override
  Future<Either<Failure, ExternalBookInfoEntity?>> call({
    required String title,
    required String author,
  }) => repo.resolveByTitleAuthor(title: title, author: author);
}
