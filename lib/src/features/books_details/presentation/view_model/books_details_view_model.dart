import 'package:book_library/src/core/collections/map_collection.dart';
import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/services/share/share_services.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/strategy/picks_strategy.dart';
import 'package:book_library/src/features/books/domain/usecases/get_all_books_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_progress_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/is_reading_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/set_progress_use_case.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/toggle_reading_use_case.dart';
import 'package:book_library/src/features/books_details/presentation/view_model/books_details_state_object.dart';
import 'package:book_library/src/features/books_details/services/external_book_info_resolver.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/is_favorite_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:flutter/foundation.dart';

class BookDetailsViewModel extends BaseViewModel {
  BookDetailsViewModel(
    this._resolver,
    this._isFavorite,
    this._toggleFavorite,
    this._isReading,
    this._toggleReading,
    this._getProgress,
    this._setProgress,
    this._shareService,
    this._getAll, {
    PickStrategy? similarStrategy,
  }) : _similarStrategy = similarStrategy ?? PickPopularAZ(limit: 6);

  final ExternalBookInfoResolver _resolver;
  final IsFavoriteUseCase _isFavorite;
  final ToggleFavoriteUseCase _toggleFavorite;

  final IsReadingUseCase _isReading;
  final ToggleReadingUseCase _toggleReading;
  final GetProgressUseCase _getProgress;
  final SetProgressUseCase _setProgress;

  final GetAllBooksUseCase _getAll;
  final PickStrategy _similarStrategy;

  final ShareService _shareService;

  final ValueNotifier<BookDetailsStateObject> state = ValueNotifier(
    BookDetailsStateObject.initial(InitialState()),
  );

  void init(BookEntity book) {
    state.value = state.value.copyWith(book: SuccessState<Failure, BookEntity>(book));
    _loadAll(book);
  }

  Future<void> _loadAll(BookEntity book) async {
    state.value = state.value.copyWith(state: LoadingState<Failure, BookDetailsPayload>());

    final favF = _isFavorite(book.id);
    final readF = _isReading(book.id);
    final progF = _getProgress(book.id);

    await resolveFor(book);

    final fav = (await favF).fold((_) => false, (v) => v);
    final isReading = (await readF).fold((_) => false, (v) => v);
    final progress = (await progF).fold((_) => 0, (v) => v);

    final similar = await _getAll().then(
      (e) => e.fold((_) => <BookEntity>[], (list) {
        final filtered = list.where((x) => x.id != book.id && x.author == book.author).toList();
        return _similarStrategy.pick(filtered.isEmpty ? list : filtered);
      }),
    );

    state.value = state.value.copyWith(
      state: SuccessState<Failure, BookDetailsPayload>(
        BookDetailsPayload(book: book, info: state.value.byBookId[book.id]),
      ),
      isFavorite: fav,
      isReading: isReading,
      progress: progress,
      similar: similar,
    );
  }

  bool hasInfoFor(String bookId) => state.value.byBookId.containsKey(bookId);

  Future<void> resolveFor(BookEntity book) async {
    if (isDisposed || hasInfoFor(book.id)) return;
    final info = await _resolver.resolve(book.title, book.author);
    if (isDisposed || info == null) return;
    final nextMap = copyWithEntry(state.value.byBookId, book.id, info);
    state.value = state.value.copyWith(byBookId: nextMap);
  }

  Future<void> shareCurrent() async {
    final st = state.value;
    final BookEntity? book = st.state.successOrNull?.book ?? st.book.successOrNull;

    if (book == null) {
      emit(ShowSnackBar('Nothing to share yet'));
      return;
    }

    final title = book.title;
    final author = book.author;

    final text = '“$title” by $author';
    await _shareService.shareText(text, subject: 'Check this book');
  }

  Future<void> toggleFavorite() async {
    final s = state.value;
    final res = await _toggleFavorite(s.book.successOrNull!.id);
    res.fold(
      (f) => emit(ShowErrorSnackBar(f.message)),
      (_) => state.value = s.copyWith(isFavorite: !s.isFavorite),
    );
  }

  Future<void> toggleReading() async {
    final s = state.value;
    final res = await _toggleReading(s.book.successOrNull!.id);
    res.fold((f) => emit(ShowErrorSnackBar(f.message)), (isReading) {
      state.value = s.copyWith(isReading: isReading);

      if (isReading && s.progress == 0) _setProgressSafe(1);
    });
  }

  Future<void> _setProgressSafe(int p) async {
    final id = state.value.book.successOrNull!.id;
    final res = await _setProgress(id, p.clamp(0, 100));
    res.fold((f) => emit(ShowErrorSnackBar(f.message)), (_) {
      state.value = state.value.copyWith(progress: p.clamp(0, 100));
    });
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}
