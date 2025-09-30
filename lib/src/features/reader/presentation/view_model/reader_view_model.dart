import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/services/reader/reader_content_service.dart';
import 'package:book_library/src/core/services/reader/reader_progress_service.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/viewmodel/base_view_model.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/use_cases/get_progress_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/is_favorite_use_case.dart';
import 'package:book_library/src/features/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/services/page_estimator.dart';
import 'package:book_library/src/features/reader/domain/use_cases/get_reader_settings_use_case.dart';
import 'package:book_library/src/features/reader/domain/use_cases/write_reader_settings_use_case.dart';
import 'package:book_library/src/features/reader/presentation/mapper/reader_settings_mapper.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';
import 'package:flutter/material.dart';

class ReaderViewModel extends BaseViewModel {
  ReaderViewModel(
    this._getReaderSettings,
    this._setReaderSettings,
    this._getProgress,
    this._content,
    this._isFavoriteUseCase,
    this._toggleFavorite,
    this._progress, {
    ReaderSettingsUiMapper? mapper,
    PageEstimator? pageEstimator,
  }) : _pageEstimator = pageEstimator ?? const DensityPageEstimator(),
       _mapper = mapper ?? ReaderSettingsUiMapper();

  final GetReaderSettingsUseCase _getReaderSettings;
  final SetReaderSettingsUseCase _setReaderSettings;
  final IsFavoriteUseCase _isFavoriteUseCase;
  final ToggleFavoriteUseCase _toggleFavorite;
  final GetProgressUseCase _getProgress;

  final ReaderContentService _content;
  final ReaderProgressService _progress;
  final PageEstimator _pageEstimator;
  final ReaderSettingsUiMapper _mapper;

  final ValueNotifier<ReaderStateObject> state = ValueNotifier(ReaderStateObject.initial());

  Future<void> init({required BookEntity book, required String assetPath}) async {
    if (isDisposed) return;
    state.value = state.value.copyWith(state: LoadingState());

    final settingsEntity = await _getReaderSettings().then(
      (e) => e.fold((_) => const ReaderSettingsEntity(), (v) => v),
    );
    if (isDisposed) return;
    state.value = state.value.copyWith(settings: _mapper.toUi(settingsEntity));

    final favF = _isFavoriteUseCase(book.id);
    final fav = (await favF).fold((_) => false, (v) => v);

    if (isDisposed) return;
    state.value = state.value.copyWith(isFavorite: fav);

    final initialProgress = await _getProgress(book.id).then((e) => e.fold((_) => 0, (v) => v));

    final either = await _content
        .loadFromAsset(assetPath)
        .then<ViewModelState<Failure, ReaderPayload>>(
          (data) => SuccessState(ReaderPayload(book: book, paragraphs: data)),
        )
        .catchError(
          (e, st) => ErrorState<Failure, ReaderPayload>(
            NetworkFailure('Failed to open EPUB', cause: e, stackTrace: st),
          ),
        );

    if (isDisposed) return;
    state.value = state.value.copyWith(state: either, progress: initialProgress);

    if (either is! SuccessState<Failure, ReaderPayload>) return;

    final pars = either.success.paragraphs;
    final s = state.value.settings;
    final total = _pageEstimator.estimateTotalPages(
      paragraphCount: pars.length,
      fontSize: s.fontSize,
      lineHeight: s.lineHeight,
    );

    if (isDisposed) return;
    state.value = state.value.copyWith(
      totalPages: total,
      currentPage: _pageFromProgress(total, initialProgress),
    );
  }

  Future<void> setFont(double size) async {
    if (isDisposed) return;

    final nextUi = state.value.settings.copyWith(fontSize: size);
    state.value = state.value.copyWith(settings: nextUi);

    final currentEntity = await _getReaderSettings().then(
      (e) => e.fold((_) => const ReaderSettingsEntity(), (v) => v),
    );
    if (isDisposed) return;
    await _setReaderSettings(_mapper.toEntity(nextUi, currentEntity));

    await _reestimateFromSettings();
  }

  Future<void> setLine(ReaderLineHeight h) async {
    if (isDisposed) return;

    final nextUi = state.value.settings.copyWith(lineHeight: h);
    state.value = state.value.copyWith(settings: nextUi);

    final currentEntity = await _getReaderSettings().then(
      (e) => e.fold((_) => const ReaderSettingsEntity(), (v) => v),
    );
    if (isDisposed) return;
    await _setReaderSettings(_mapper.toEntity(nextUi, currentEntity));

    await _reestimateFromSettings();
  }

  Future<void> onScrollRatioChanged(double ratio) async {
    if (isDisposed) return;

    final total = state.value.totalPages;
    final (page, percent) = _progress.compute(total, ratio, state.value.progress);

    if (page != state.value.currentPage) {
      if (isDisposed) return;
      state.value = state.value.copyWith(currentPage: page);
    }
    if (percent != state.value.progress) {
      if (isDisposed) return;
      state.value = state.value.copyWith(progress: percent);
      final id = state.value.state.successOrNull?.book.id;
      if (id != null) {
        await _progress.saveDebounced(id, percent);
      }
    }
  }

  void setOpenPanel(ReaderPanel panel) {
    if (isDisposed) return;
    state.value = state.value.copyWith(openPanel: panel);
  }

  Future<void> toggleFavorite() async {
    final s = state.value;
    final res = await _toggleFavorite((s.state).successOrNull?.book.id ?? '');
    res.fold(
      (f) => emit(ShowErrorSnackBar(f.message)),
      (_) => state.value = s.copyWith(isFavorite: !s.isFavorite),
    );
  }

  Future<void> _reestimateFromSettings() async {
    if (isDisposed) return;

    final payload = state.value.state.successOrNull;
    if (payload == null) return;

    final pars = payload.paragraphs;
    final s = state.value.settings;

    final total = _pageEstimator.estimateTotalPages(
      paragraphCount: pars.length,
      fontSize: s.fontSize,
      lineHeight: s.lineHeight,
    );

    final oldTotal = state.value.totalPages.clamp(1, 999);
    final oldPage = state.value.currentPage.clamp(1, oldTotal);
    final ratio = oldTotal <= 1 ? 0.0 : (oldPage - 1) / (oldTotal - 1);

    final newPage = (ratio * (total - 1)).round() + 1;
    final newPercent = total <= 1
        ? 100
        : ((newPage - 1) * (100 / (total - 1))).round().clamp(0, 100);

    if (isDisposed) return;
    state.value = state.value.copyWith(
      totalPages: total,
      currentPage: newPage,
      progress: newPercent,
    );
  }

  int _pageFromProgress(int total, int progress) {
    if (total <= 1) return 1;
    final page = ((progress / 100) * (total - 1)).round() + 1;
    return page.clamp(1, total);
  }
}
