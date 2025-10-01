import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/types/book_info_id.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:equatable/equatable.dart';

class BookDetailsStateObject extends Equatable {
  factory BookDetailsStateObject.initial(ViewModelState<Failure, BookEntity> book) =>
      BookDetailsStateObject(
        state: InitialState<Failure, BookDetailsPayload>(),
        book: book,
        byBookId: const {},
        isFavorite: false,
        isReading: false,
        progress: 0,
        similar: const [],
      );

  const BookDetailsStateObject({
    required this.state,
    required this.book,
    required this.byBookId,
    required this.isFavorite,
    required this.isReading,
    required this.progress,
    required this.similar,
  });

  final ViewModelState<Failure, BookDetailsPayload> state;
  final ViewModelState<Failure, BookEntity> book;
  final BookInfoById byBookId;
  final bool isFavorite;
  final bool isReading;
  final int progress;
  final List<BookEntity> similar;

  BookDetailsStateObject copyWith({
    ViewModelState<Failure, BookDetailsPayload>? state,
    ViewModelState<Failure, BookEntity>? book,
    BookInfoById? byBookId,
    bool? isFavorite,
    bool? isReading,
    int? progress,
    List<BookEntity>? similar,
  }) {
    return BookDetailsStateObject(
      state: state ?? this.state,
      book: book ?? this.book,
      byBookId: byBookId ?? this.byBookId,
      isFavorite: isFavorite ?? this.isFavorite,
      isReading: isReading ?? this.isReading,
      progress: progress ?? this.progress,
      similar: similar ?? this.similar,
    );
  }

  @override
  List<Object?> get props => [state, book, byBookId, isFavorite, isReading, progress, similar];
}

class BookDetailsPayload extends Equatable {
  const BookDetailsPayload({required this.book, required this.info});

  final BookEntity book;
  final ExternalBookInfoEntity? info;

  BookDetailsPayload copyWith({BookEntity? book, ExternalBookInfoEntity? info}) =>
      BookDetailsPayload(book: book ?? this.book, info: info ?? this.info);

  @override
  List<Object?> get props => [book, info];
}
