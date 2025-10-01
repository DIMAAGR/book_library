import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:book_library/src/features/search/presentation/view_model/search_state_object.dart';
import 'package:book_library/src/features/search/presentation/view_model/search_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late SearchViewModel vm;
  late MockGetAllBooksUseCase mockGetAll;
  late MockGetBookByTitleUseCase mockGetByTitle;
  late MockGetFavoritesIdsUseCase mockGetFavs;
  late MockToggleFavoriteUseCase mockToggleFav;
  late MockExternalBookInfoResolver mockResolver;

  const b1 = BookEntity(id: '1', title: 'Clean Code', author: 'Robert C. Martin');
  const b2 = BookEntity(id: '2', title: 'The Pragmatic Programmer', author: 'Andrew Hunt');

  setUp(() {
    mockGetAll = MockGetAllBooksUseCase();
    mockGetByTitle = MockGetBookByTitleUseCase();
    mockGetFavs = MockGetFavoritesIdsUseCase();
    mockToggleFav = MockToggleFavoriteUseCase();
    mockResolver = MockExternalBookInfoResolver();

    vm = SearchViewModel(mockGetAll, mockGetByTitle, mockGetFavs, mockToggleFav, mockResolver);
  });

  group('init()', () {
    test('carrega favoritos e lista inicial via getAll', () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right({'1'}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b1, b2]));

      await vm.init();

      final s = vm.state.value;
      expect(s.favorites, {'1'});
      expect(s.state, isA<SuccessState<Failure, SearchPayload>>());

      final payload = (s.state as SuccessState<Failure, SearchPayload>).success;
      expect(payload.items, [b1, b2]);
    });

    test('erro no getAll => ErrorState + evento', () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Left(NetworkFailure('net down')));

      await vm.init();

      expect(vm.state.value.state, isA<ErrorState<Failure, SearchPayload>>());
      expect(vm.event.value, isNotNull);
    });
  });

  group('filtros', () {
    setUp(() async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b2, b1]));
      await vm.init();
      vm.consumeEvent();
    });

    test('setSort aplica ordenação no sucesso atual', () async {
      expect(vm.state.value.state, isA<SuccessState<Failure, SearchPayload>>());

      vm.setSort(const SortByAZ());
      final s = vm.state.value;
      final payload = (s.state as SuccessState<Failure, SearchPayload>).success;

      expect(payload.items.map((e) => e.title).toList(), [
        'Clean Code',
        'The Pragmatic Programmer',
      ]);
      expect(s.filters.sort.runtimeType, SortByAZ);
    });

    test('setRange atualiza filtro e reexecuta busca (mantém Success)', () async {
      vm.setRange(PublishedRange.recent2020plus);
      final s = vm.state.value;
      expect(s.filters.range, PublishedRange.recent2020plus);
      expect(s.state, isA<SuccessState<Failure, SearchPayload>>());
    });

    test('clearAllFilterSelection reseta filtros e mantém Success', () async {
      vm.setSort(const SortByOldest());
      vm.setRange(PublishedRange.classicBefore2000);

      await vm.clearAllFilterSelection();

      final s = vm.state.value;
      expect(s.filters.sort.runtimeType, SortByAZ);
      expect(s.filters.range, PublishedRange.any);
      expect(s.state, isA<SuccessState<Failure, SearchPayload>>());
    });
  });

  group('toggleFavorite()', () {
    test('atualiza favorites dentro do StateObject', () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b1]));
      when(mockToggleFav('1')).thenAnswer((_) async => const Right({'1'}));

      await vm.init();
      await vm.toggleFavorite('1');

      expect(vm.state.value.favorites, {'1'});
      verify(mockToggleFav('1')).called(1);
    });
  });

  group('resolveFor()', () {
    test('resolveCoverIfMissing chama UMA vez quando não está no mapa', () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b1]));
      when(mockResolver.prefetch(any)).thenAnswer((_) async {});
      when(
        mockResolver.resolve(b1.title, b1.author),
      ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 'Clean Code', isbn13: '123'));

      await vm.init();
      vm.consumeEvent();

      vm.state.value = vm.state.value.copyWith(byBookId: {});

      await vm.resolveCoverIfMissing(b1);
      expect(vm.state.value.byBookId.containsKey('1'), isTrue);
      reset(mockResolver);
      await vm.resolveCoverIfMissing(b1);
      verifyZeroInteractions(mockResolver);

      expect(vm.state.value.byBookId['1']?.isbn13, '123');
    });

    test('resolveCoverIfMissing NÃO chama quando já há info no mapa', () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b1]));
      when(mockResolver.prefetch(any)).thenAnswer((_) async {});

      await vm.init();
      vm.consumeEvent();

      vm.state.value = vm.state.value.copyWith(
        byBookId: const {'1': ExternalBookInfoEntity(title: 'Clean Code', isbn13: '123')},
      );

      clearInteractions(mockResolver);

      await vm.resolveCoverIfMissing(b1);
      await vm.resolveCoverIfMissing(b1);

      verifyNever(mockResolver.resolve(b1.title, b1.author));
    });
  });

  group('onTextChanged() + busca por título', () {
    test('quando há texto, chama getByTitle e retorna Success', () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b1, b2]));
      when(mockGetByTitle('clean')).thenAnswer((_) async => const Right([b1]));

      await vm.init();

      vm.onTextChanged('clean');
      await Future<void>.delayed(const Duration(milliseconds: 360));

      final st = vm.state.value.state;
      expect(st, isA<SuccessState<Failure, SearchPayload>>());
      final items = (st as SuccessState<Failure, SearchPayload>).success.items;
      expect(items, [b1]);
    });
  });
}
