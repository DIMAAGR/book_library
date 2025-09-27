import 'package:book_library/src/features/books/data/models/book_model.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:intl/intl.dart';

abstract class BookMapper {
  static BookEntity toEntity(BookModel model) {
    DateTime? publishedDate;
    final raw = model.published?.trim();
    if (raw != null && raw.isNotEmpty) {
      try {
        publishedDate =
            DateTime.tryParse(raw) ?? DateFormat('yyyy-MM-dd').parse(raw, true).toLocal();
      } catch (_) {}
    }

    return BookEntity(
      id: model.id,
      title: model.title,
      author: model.author,
      published: publishedDate,
      publisher: model.publisher,
    );
  }

  static BookModel toModel(BookEntity entity) {
    return BookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      published: entity.published?.toIso8601String(),
      publisher: entity.publisher,
    );
  }
}
