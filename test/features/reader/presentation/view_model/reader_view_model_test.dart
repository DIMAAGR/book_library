import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/models/reader_paragraph.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/reader/domain/entity/reader_settings_entity.dart';
import 'package:book_library/src/features/reader/domain/services/page_estimator.dart';
import 'package:book_library/src/features/reader/domain/value_objects/font_size_object.dart';
import 'package:book_library/src/features/reader/domain/value_objects/line_height_object.dart';
import 'package:book_library/src/features/reader/presentation/mapper/reader_settings_mapper.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

final fakeParagraphs = <ReaderParagraph>[
  const ReaderParagraph(title: 'Capítulo 1', text: 'Primeiro parágrafo.'),
  const ReaderParagraph(title: '', text: 'Segundo parágrafo.'),
  const ReaderParagraph(title: '', text: 'Terceiro parágrafo.'),
];

class TestEstimator implements PageEstimator {
  TestEstimator({required this.pages});
  int pages;
  @override
  int estimateTotalPages({
    required int paragraphCount,
    double? fontSize,
    ReaderLineHeight? lineHeight,
  }) {
    return pages;
  }
}

void main() {
  late MockReaderContentService mockContent;
  late MockReaderProgressService mockProgressSvc;

  late MockGetReaderSettingsUseCase mockGetSettings;
  late MockSetReaderSettingsUseCase mockSetSettings;

  late MockGetProgressUseCase mockGetProgress;

  late MockIsFavoriteUseCase mockIsFavorite;
  late MockToggleFavoriteUseCase mockToggleFavorite;

  late PageEstimator estimator;

  late ReaderViewModel vm;

  const book = BookEntity(id: 'b1', title: 'Clean Code', author: 'Robert C. Martin');

  List<ReaderParagraph> paragraphs48() =>
      List.generate(48, (i) => ReaderParagraph(title: i < 5 ? 'Ch.1' : 'Ch.2', text: 'p$i'));

  setUp(() {
    mockContent = MockReaderContentService();
    mockProgressSvc = MockReaderProgressService();
    mockGetSettings = MockGetReaderSettingsUseCase();
    mockSetSettings = MockSetReaderSettingsUseCase();
    mockGetProgress = MockGetProgressUseCase();
    mockIsFavorite = MockIsFavoriteUseCase();
    mockToggleFavorite = MockToggleFavoriteUseCase();

    estimator = TestEstimator(pages: 10);

    when(mockGetSettings.call()).thenAnswer((_) async => const Right(ReaderSettingsEntity()));
    when(mockGetProgress.call(any)).thenAnswer((_) async => const Right(0));
    when(mockIsFavorite.call(any)).thenAnswer((_) async => const Right(false));
    when(mockContent.loadFromAsset(any)).thenAnswer((_) async => paragraphs48());

    when(mockProgressSvc.compute(any, any, any)).thenAnswer((inv) {
      final total = inv.positionalArguments[0] as int;
      final ratio = inv.positionalArguments[1] as double;

      final page = (ratio * (total - 1)).round() + 1;
      final percent = total <= 1 ? 100 : ((page - 1) * (100 / (total - 1))).round().clamp(0, 100);
      return (page, percent);
    });
    when(mockProgressSvc.saveDebounced(any, any)).thenAnswer((_) async {});

    vm = ReaderViewModel(
      mockGetSettings,
      mockSetSettings,
      mockGetProgress,
      mockContent,
      mockIsFavorite,
      mockToggleFavorite,
      mockProgressSvc,
      pageEstimator: estimator,
      mapper: ReaderSettingsUiMapper(),
    );
  });

  group('init', () {
    test('carrega settings, favorito, progresso, conteúdo e calcula páginas', () async {
      when(mockIsFavorite.call(book.id)).thenAnswer((_) async => const Right(true));

      when(mockGetProgress.call(book.id)).thenAnswer((_) async => const Right(30));

      (estimator as TestEstimator).pages = 12;

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      final st = vm.state.value.state;
      expect(st, isA<SuccessState<Failure, ReaderPayload>>());
      expect(vm.state.value.isFavorite, true);
      expect(vm.state.value.totalPages, 12);
      expect(vm.state.value.currentPage, 4);
      expect(vm.state.value.settings.fontSize, 18.0);
      expect(vm.state.value.settings.lineHeight, ReaderLineHeight.comfortable);

      verify(mockGetSettings.call()).called(1);
      verify(mockIsFavorite.call(book.id)).called(1);
      verify(mockGetProgress.call(book.id)).called(1);
      verify(mockContent.loadFromAsset(any)).called(1);
      verifyNoMoreInteractions(mockGetSettings);
      verifyNoMoreInteractions(mockIsFavorite);
      verifyNoMoreInteractions(mockGetProgress);
      verifyNoMoreInteractions(mockContent);
    });

    test('propaga erro do conteúdo como ErrorState', () async {
      when(mockContent.loadFromAsset(any)).thenAnswer((_) => Future.error(Exception('boom')));

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      final st = vm.state.value.state;
      expect(st, isA<ErrorState<Failure, ReaderPayload>>());
    });
  });

  group('open panel', () {
    test('setOpenPanel altera openPanel', () {
      vm.setOpenPanel(ReaderPanel.fontSize);
      expect(vm.state.value.openPanel, ReaderPanel.fontSize);
      vm.setOpenPanel(ReaderPanel.none);
      expect(vm.state.value.openPanel, ReaderPanel.none);
    });
  });

  group('onScrollRatioChanged', () {
    test('atualiza página e progresso e chama saveDebounced quando mudar', () async {
      (estimator as TestEstimator).pages = 6;

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      await vm.onScrollRatioChanged(0.5);

      expect(vm.state.value.currentPage, 4);
      expect(vm.state.value.progress, 60);

      verify(mockProgressSvc.compute(6, 0.5, any)).called(1);
      verify(mockProgressSvc.saveDebounced('b1', 60)).called(1);
    });

    test('não chama saveDebounced se percent não mudou', () async {
      (estimator as TestEstimator).pages = 3;

      when(mockContent.loadFromAsset(any)).thenAnswer((_) async => fakeParagraphs);

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      when(mockProgressSvc.compute(3, any, any)).thenReturn((1, 0));

      await vm.onScrollRatioChanged(0.0);
      await vm.onScrollRatioChanged(0.01);

      verifyNever(mockProgressSvc.saveDebounced(any, any));

      verify(mockProgressSvc.compute(3, any, any)).called(2);
    });

    test('chama saveDebounced uma vez quando percent muda', () async {
      (estimator as TestEstimator).pages = 3;
      when(mockContent.loadFromAsset(any)).thenAnswer((_) async => fakeParagraphs);

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      when(mockProgressSvc.compute(3, 0.0, any)).thenReturn((1, 0));
      await vm.onScrollRatioChanged(0.0);

      when(mockProgressSvc.compute(3, 0.26, any)).thenReturn((2, 50));
      await vm.onScrollRatioChanged(0.26);

      verify(mockProgressSvc.saveDebounced(book.id, 50)).called(1);
    });
  });

  group('setFont / setLine (reestima preservando posição)', () {
    test('setFont persiste settings e reestima páginas mantendo razão', () async {
      (estimator as TestEstimator).pages = 10;

      when(mockGetSettings.call()).thenAnswer((_) async => const Right(ReaderSettingsEntity()));
      when(mockSetSettings.call(any)).thenAnswer((_) async => const Right(null));

      when(mockContent.loadFromAsset(any)).thenAnswer((_) async => fakeParagraphs);

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      vm.state.value = vm.state.value.copyWith(totalPages: 10, currentPage: 6);

      (estimator as TestEstimator).pages = 20;

      await vm.setFont(22.0);

      expect(vm.state.value.totalPages, 20);
      expect(vm.state.value.currentPage, 12);
      expect(vm.state.value.progress, ((12 - 1) * (100 / (20 - 1))).round());

      final captured =
          verify(mockSetSettings.call(captureAny)).captured.single as ReaderSettingsEntity;
      expect(captured.fontSize, isInstanceOf<FontSizeVO>());
      expect(captured.lineHeight, LineHeightVO.comfortable);

      verify(mockGetSettings.call()).called(greaterThanOrEqualTo(2));
      verifyNoMoreInteractions(mockSetSettings);
    });

    test('setLine persiste settings e reestima páginas mantendo razão', () async {
      (estimator as TestEstimator).pages = 8;
      when(mockSetSettings.call(any)).thenAnswer((_) async => const Right(null));

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      vm.state.value = vm.state.value.copyWith(totalPages: 8, currentPage: 3);
      (estimator as TestEstimator).pages = 16;

      await vm.setLine(ReaderLineHeight.spacious);

      final expectedPage = ((0.2857 * (16 - 1)).round()) + 1;
      expect(vm.state.value.totalPages, 16);
      expect(vm.state.value.currentPage, expectedPage);
      expect(vm.state.value.progress, ((expectedPage - 1) * (100 / (16 - 1))).round());

      verify(mockSetSettings.call(any)).called(1);
    });
  });

  group('toggleFavorite', () {
    test('sucesso: alterna flag local', () async {
      when(mockToggleFavorite.call(book.id)).thenAnswer((_) async => const Right({}));

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      final before = vm.state.value.isFavorite;
      await vm.toggleFavorite();
      expect(vm.state.value.isFavorite, !before);

      verify(mockToggleFavorite.call(book.id)).called(1);
    });

    test('falha: emite ShowErrorSnackBar e não altera estado', () async {
      when(
        mockToggleFavorite.call(book.id),
      ).thenAnswer((_) async => const Left(StorageFailure('fail')));

      await vm.init(book: book, assetPath: 'assets/epub/example.epub');

      final before = vm.state.value.isFavorite;

      bool gotError = false;
      vm.event.addListener(() {
        final e = vm.event.value;
        if (e is ShowErrorSnackBar) gotError = true;
      });

      await vm.toggleFavorite();
      expect(gotError, true);
      expect(vm.state.value.isFavorite, before);

      verify(mockToggleFavorite.call(book.id)).called(1);
    });
  });
}
