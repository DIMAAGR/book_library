import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
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

  test('init: carrega favoritos e lista inicial (getAll)', () async {
    when(mockGetFavs()).thenAnswer((_) async => const Right({'1'}));
    when(mockGetAll()).thenAnswer((_) async => const Right([b1, b2]));

    await vm.init();

    expect(vm.favorites.value, {'1'});
    expect(vm.state.value, isA<SuccessState>());
    final list = (vm.state.value as SuccessState).success as List<BookEntity>;
    expect(list.length, 2);
  });

  test('applyCurrentFilterSelection: aplica sort e range e retorna SuccessState', () async {
    when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
    when(mockGetAll()).thenAnswer((_) async => const Right([b2, b1]));

    await vm.init();

    vm.sort.value = const SortByAZ();
    await vm.applyCurrentFilterSelection();

    expect(vm.state.value, isA<SuccessState>());
    final list = (vm.state.value as SuccessState).success as List<BookEntity>;
    expect(list.map((e) => e.title).toList(), ['Clean Code', 'The Pragmatic Programmer']);
  });

  test('clearAllFilterSelection: reseta filtros e recarrega', () async {
    when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
    when(mockGetAll()).thenAnswer((_) async => const Right([b1]));

    await vm.init();
    vm.sort.value = const SortByOldest();
    vm.range.value = PublishedRange.recent2020plus;

    await vm.clearAllFilterSelection();

    expect(vm.sort.value, isA<SortByAZ>());
    expect(vm.range.value, PublishedRange.any);
    expect(vm.state.value, isA<SuccessState>());
  });

  test('toggleFavorite: atualiza favorites ValueNotifier', () async {
    when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
    when(mockGetAll()).thenAnswer((_) async => const Right([b1]));
    when(mockToggleFav('1')).thenAnswer((_) async => const Right({'1'}));

    await vm.init();
    await vm.toggleFavorite('1');

    expect(vm.favorites.value, {'1'});
    verify(mockToggleFav('1')).called(1);
  });

  test(
    'resolveFor: usa resolver e atualiza byBookId; chamadas duplicadas coalescem pelo map',
    () async {
      when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
      when(mockGetAll()).thenAnswer((_) async => const Right([b1]));

      when(
        mockResolver.resolve(b1.title, b1.author),
      ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 'Clean Code', isbn13: '123'));

      await vm.init();
      await vm.resolveFor(b1);
      await vm.resolveFor(b1);

      expect(vm.byBookId.value.containsKey('1'), true);
      expect(vm.byBookId.value['1']?.isbn13, '123');

      verify(mockResolver.resolve(b1.title, b1.author)).called(1);
    },
  );

  test('erro no getAll => ErrorState e ShowErrorSnackBar', () async {
    when(mockGetFavs()).thenAnswer((_) async => const Right(<String>{}));
    when(mockGetAll()).thenAnswer((_) async => const Left(NetworkFailure('net down')));

    await vm.init();

    expect(vm.state.value, isA<ErrorState>());
    expect(vm.event.value, isNotNull);
  });
}
