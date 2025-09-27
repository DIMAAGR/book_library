import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/features/books_details/data/datasources/external_catalog_remote_data_source.dart';
import 'package:book_library/src/features/books_details/data/mappers/external_book_info_mapper.dart';
import 'package:book_library/src/features/books_details/data/models/external_book_info_model.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/domain/repositories/book_details_repository.dart';
import 'package:dartz/dartz.dart';

class ExternalBookInfoRepositoryImpl implements ExternalBookInfoRepository {
  ExternalBookInfoRepositoryImpl(this.remote);
  final ExternalCatalogRemoteDataSource remote;

  @override
  Future<Either<Failure, ExternalBookInfoEntity?>> resolveByTitleAuthor({
    required String title,
    required String author,
  }) async {
    try {
      final json = await remote.findByTitleAuthor(title: title, author: author);
      final model = ExternalCatalogVolumeModel.fromRootJson(json);
      return Right(ExternalBookInfoMapper.toEntityOrNull(model));
    } catch (e, s) {
      return Left(NetworkFailure('Failed to resolve external book info', cause: e, stackTrace: s));
    }
  }
}
