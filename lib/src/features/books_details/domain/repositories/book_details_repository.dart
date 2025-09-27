import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ExternalBookInfoRepository {
  Future<Either<Failure, ExternalBookInfoEntity?>> resolveByTitleAuthor({
    required String title,
    required String author,
  });
}
