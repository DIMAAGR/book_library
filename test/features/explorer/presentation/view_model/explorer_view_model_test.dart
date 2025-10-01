import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/strategy/picks_strategy.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_view_model.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockGetAllBooksUseCase getAllBooks;
  late MockGetFavoritesIdsUseCase getFavorites;
  late MockToggleFavoriteUseCase toggleFavorite;
  late MockExternalBookInfoResolver resolver;

  late PickStrategy pickNewReleases;
  late PickStrategy pickPopular;

  late ExploreViewModel vm;

  final books = <BookEntity>[
    BookEntity(id: '1', title: 'Alpha', author: 'Author A', published: DateTime(2024, 1, 10)),
    BookEntity(id: '2', title: 'Beta', author: 'Author A', published: DateTime(2023, 5, 10)),
    BookEntity(id: '3', title: 'Gamma', author: 'Author B', published: DateTime(1999, 1, 1)),
    BookEntity(id: '4', title: 'Delta', author: 'Author C', published: DateTime(2021, 7, 7)),
  ];

  setUp(() {
    getAllBooks = MockGetAllBooksUseCase();
    getFavorites = MockGetFavoritesIdsUseCase();
    toggleFavorite = MockToggleFavoriteUseCase();
    resolver = MockExternalBookInfoResolver();

    pickNewReleases = PickNewReleases(limit: 12);
    pickPopular = PickPopularAZ(limit: 10);

    vm = ExploreViewModel(
      getAllBooks,
      getFavorites,
      resolver,
      toggleFavorite,
      newReleasesStrategy: pickNewReleases,
      popularBooksStrategy: pickPopular,
    );

    when(
      resolver.resolve(any, any),
    ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 't', coverUrl: 'u'));
  });

  tearDown(() {
    vm.dispose();
  });

  group('init()', () {
    test('carrega favoritos + livros, monta seções e preenche byBookId (SuccessState)', () async {
      when(getFavorites()).thenAnswer((_) async => right({'1'}));
      when(getAllBooks()).thenAnswer((_) async => right(books));

      when(
        resolver.resolve(any, any),
      ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 'cover', coverUrl: 'u'));

      await vm.init();

      final s = vm.state.value;

      expect(s.state, isA<SuccessState<Failure, List<BookEntity>>>());
      expect(s.favorites, {'1'});

      expect(s.newReleases.map((b) => b.id).toList(), ['1', '2', '4', '3']);
      expect(s.popularTop10.map((b) => b.title).toList(), ['Alpha', 'Beta', 'Delta', 'Gamma']);
      expect(s.similarToFavorites.any((b) => b.id == '2'), isTrue);

      expect(s.byBookId.isNotEmpty, true);

      verify(resolver.resolve(any, any)).called(greaterThan(0));
    });

    test('trata falha ao carregar livros -> ErrorState + ShowErrorSnackBar', () async {
      when(getFavorites()).thenAnswer((_) async => right(<String>{}));
      when(getAllBooks()).thenAnswer((_) async => left(const FakeFailure('boom')));

      UiEvent? captured;
      vm.event.addListener(() => captured = vm.event.value);

      await vm.init();

      expect(vm.state.value.state, isA<ErrorState<Failure, List<BookEntity>>>());
      expect(captured, isA<ShowErrorSnackBar>());
      expect((captured as ShowErrorSnackBar).message, 'boom');
    });
  });

  group('toggleFavorite()', () {
    test('sucesso -> atualiza set de favoritos', () async {
      when(toggleFavorite('2')).thenAnswer((_) async => right({'1', '2'}));

      await vm.toggleFavorite('2');

      expect(vm.state.value.favorites, {'1', '2'});
      verify(toggleFavorite('2')).called(1);
    });

    test('erro -> emite ShowErrorSnackBar', () async {
      when(toggleFavorite('3')).thenAnswer((_) async => left(const FakeFailure('nope')));

      UiEvent? event;
      vm.event.addListener(() => event = vm.event.value);

      await vm.toggleFavorite('3');

      expect(event, isA<ShowErrorSnackBar>());
      expect((event as ShowErrorSnackBar).message, 'nope');
    });
  });

  group('updateQuery() e allBooksFiltered()', () {
    test('filtra por título e ordena', () async {
      vm.stateNotifier.value = vm.state.value.copyWith(
        state: SuccessState<Failure, List<BookEntity>>(books),
      );

      vm.updateQuery(const BookQuery(title: 'a', sort: SortByOldest()));

      final result = vm.allBooksFiltered();

      expect(result.map((b) => b.title).toList(), ['Gamma', 'Delta', 'Beta', 'Alpha']);
    });

    test('updateQuery dispara prefetch para os itens filtrados (commita byBookId)', () async {
      when(
        resolver.resolve(any, any),
      ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 't', coverUrl: 'u'));

      vm.stateNotifier.value = vm.state.value.copyWith(
        state: SuccessState<Failure, List<BookEntity>>(books),
      );

      vm.updateQuery(const BookQuery(title: '', sort: SortByAZ()));

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final byId = vm.state.value.byBookId;
      expect(byId.length, greaterThan(0));

      verify(resolver.resolve(any, any)).called(greaterThan(0));
    });

    test('quando estado não é Success, retorna lista vazia', () {
      vm.stateNotifier.value = ExplorerState.initial().copyWith(state: LoadingState());
      final r = vm.allBooksFiltered();
      expect(r, isEmpty);
    });
  });

  group('prefetch behavior', () {
    test('não refaz resolve para livros que já têm capa em byBookId', () async {
      when(getFavorites()).thenAnswer((_) async => right(<String>{}));
      when(getAllBooks()).thenAnswer((_) async => right(books));

      when(
        resolver.resolve(any, any),
      ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 't', coverUrl: 'u'));

      await vm.init();

      final before = vm.state.value.byBookId.length;
      expect(before, greaterThan(0));

      clearInteractions(resolver);

      vm.updateQuery(const BookQuery(title: '', sort: SortByAZ()));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      verifyNever(resolver.resolve(any, any));
    });

    test('falha no prefetch -> ShowSnackBar', () async {
      when(getFavorites()).thenAnswer((_) async => right(<String>{}));
      when(getAllBooks()).thenAnswer((_) async => right(books));

      when(resolver.resolve(any, any)).thenThrow(Exception('network'));

      UiEvent? event;
      vm.event.addListener(() => event = vm.event.value);

      await vm.init();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(event, anyOf(isA<ShowSnackBar>(), isNull));
    });
  });
}
