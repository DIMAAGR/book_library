import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/repositories/books_repository.dart';
import 'package:dartz/dartz.dart';

abstract class GetAllBooksUseCase {
  const GetAllBooksUseCase();

  Future<Either<Failure, List<BookEntity>>> call();
}

class GetAllBooksUseCaseImpl extends GetAllBooksUseCase {
  const GetAllBooksUseCaseImpl(this.repository);
  final BooksRepository repository;

  @override
  Future<Either<Failure, List<BookEntity>>> call() => repository.getAll();
}
