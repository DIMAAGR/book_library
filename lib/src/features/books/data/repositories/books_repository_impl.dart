import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books/data/datasources/books_remote_data_source/books_remote_data_source.dart';
import 'package:book_library/src/features/books/data/mappers/book_mapper.dart';
import 'package:book_library/src/features/books/data/models/book_model.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/repositories/books_repository.dart';
import 'package:dartz/dartz.dart';

class BooksRepositoryImpl implements BooksRepository {
  const BooksRepositoryImpl(this.remote);
  final BooksRemoteDataSource remote;

  @override
  Future<Either<Failure, List<BookEntity>>> getAll() async {
    try {
      final raw = await remote.fetchBooks();
      final entities = raw
          .map((m) => BookMapper.toEntity(BookModel.fromJson(m)))
          .toList(growable: false);
      return Right(entities);
    } catch (e, s) {
      return Left(NetworkFailure('Failed to fetch books', cause: e, stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> searchByTitle(String query) async {
    try {
      final raw = await remote.fetchBooks();
      final q = query.trim().toLowerCase();
      final entities = raw
          .map((m) => BookMapper.toEntity(BookModel.fromJson(m)))
          .where((b) => b.title.toLowerCase().contains(q))
          .toList(growable: false);
      return Right(entities);
    } catch (e, s) {
      return Left(NetworkFailure('Failed to search books', cause: e, stackTrace: s));
    }
  }
}
