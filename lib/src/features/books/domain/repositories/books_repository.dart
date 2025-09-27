import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:dartz/dartz.dart';

abstract class BooksRepository {
  Future<Either<Failure, List<BookEntity>>> getAll();
  Future<Either<Failure, List<BookEntity>>> searchByTitle(String query);
}
