import 'package:book_library/src/features/books_details/data/models/external_book_info_model.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';

abstract class ExternalBookInfoMapper {
  static ExternalBookInfoEntity? toEntityOrNull(ExternalCatalogVolumeModel? model) {
    if (model == null) return null;
    if (model.title.isEmpty) return null;
    return ExternalBookInfoEntity(
      title: model.title,
      description: model.description,
      coverUrl: model.coverUrl,
      isbn13: model.isbn13,
    );
  }
}
