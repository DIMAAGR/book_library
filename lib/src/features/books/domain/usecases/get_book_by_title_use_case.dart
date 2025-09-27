import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/repositories/books_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetBookByTitleUseCase {
  const GetBookByTitleUseCase();

  Future<Either<Failure, List<BookEntity>>> call(String query);
}

class GetBookByTitleUseCaseImpl extends GetBookByTitleUseCase {
  const GetBookByTitleUseCaseImpl(this.repository);
  final BooksRepository repository;

  @override
  Future<Either<Failure, List<BookEntity>>> call(String query) => repository.searchByTitle(query);
}
