import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_state_object.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockGetAllBooksUseCase mockGetBooks;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockExternalBookInfoResolver mockResolver;
  late HomeViewModel vm;

  final List<BookEntity> books = List.generate(
    8,
    (i) => BookEntity(
      id: '${i + 1}',
      title: 'Book $i',
      author: 'Author $i',
      published: DateTime(2020, 1, 1),
      publisher: 'Pub',
    ),
  );

  final categories = <CategoryEntity>[
    const CategoryEntity(id: 'romance', name: 'Romance'),
    const CategoryEntity(id: 'scifi', name: 'Sci-Fi'),
  ];

  setUp(() {
    mockGetBooks = MockGetAllBooksUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockResolver = MockExternalBookInfoResolver();

    vm = HomeViewModel(mockGetBooks, mockGetCategories, mockResolver);
  });

  group('load()', () {
    test('emite SuccessState + prefetch (duas listas) e seta activeCategoryId', () async {
      when(mockGetCategories.call()).thenAnswer((_) async => Right(categories));
      when(mockGetBooks.call()).thenAnswer((_) async => Right(books));
      when(mockResolver.prefetch(any)).thenAnswer((_) async {});

      await vm.load();

      final home = vm.state.value;
      expect(home.state, isA<SuccessState<Failure, HomePayload>>());

      final payload = (home.state as SuccessState<Failure, HomePayload>).success;
      expect(payload.activeCategoryId, categories.first.id);

      expect(home.library.length, books.length ~/ 2);
      expect(home.explore.length, books.length - home.library.length);

      verify(mockResolver.prefetch(any)).called(2);
      verifyNoMoreInteractions(mockResolver);

      expect(vm.event.value, isNull);
    });

    test('falha em categorias -> ErrorState + ShowErrorSnackBar e não chama getBooks', () async {
      when(
        mockGetCategories.call(),
      ).thenAnswer((_) async => const Left(NetworkFailure('cats fail')));

      await vm.load();

      final home = vm.state.value;
      expect(home.state, isA<ErrorState<Failure, HomePayload>>());

      expect(vm.event.value, isA<ShowErrorSnackBar>());
      expect((vm.event.value as ShowErrorSnackBar).message, 'cats fail');

      verifyNever(mockGetBooks.call());
    });

    test('falha em livros -> ErrorState + ShowErrorSnackBar', () async {
      when(mockGetCategories.call()).thenAnswer((_) async => Right(categories));
      when(mockGetBooks.call()).thenAnswer((_) async => const Left(NetworkFailure('books fail')));

      await vm.load();

      final home = vm.state.value;
      expect(home.state, isA<ErrorState<Failure, HomePayload>>());

      expect(vm.event.value, isA<ShowErrorSnackBar>());
      expect((vm.event.value as ShowErrorSnackBar).message, 'books fail');
    });
  });

  group('selectCategory()', () {
    setUp(() async {
      when(mockGetCategories.call()).thenAnswer((_) async => Right(categories));
      when(mockGetBooks.call()).thenAnswer((_) async => Right(books));
      when(mockResolver.prefetch(any)).thenAnswer((_) async {});
      await vm.load();
      vm.consumeEvent();
      clearInteractions(mockResolver);
    });

    test('atualiza activeCategoryId e faz prefetch da library', () async {
      final before =
          (vm.state.value.state as SuccessState<Failure, HomePayload>).success.activeCategoryId;

      vm.selectCategory(categories.last.id);

      final after =
          (vm.state.value.state as SuccessState<Failure, HomePayload>).success.activeCategoryId;

      expect(before, isNot(equals(after)));
      expect(after, categories.last.id);
      verify(mockResolver.prefetch(any)).called(1);
    });

    test('não faz nada se escolher a mesma categoria', () async {
      final current =
          (vm.state.value.state as SuccessState<Failure, HomePayload>).success.activeCategoryId!;
      vm.selectCategory(current);
      verifyNever(mockResolver.prefetch(any));
    });
  });

  group('resolveFor()', () {
    test('resolve e popula byBookId dentro do HomeState; evita chamadas repetidas', () async {
      final b = books.first;
      const info = ExternalBookInfoEntity(
        title: 'X',
        description: 'desc',
        coverUrl: 'http://example.com/example.jpg',
        isbn13: '978...',
      );

      when(mockResolver.resolve(b.title, b.author)).thenAnswer((_) async => info);

      await vm.resolveFor(b);
      expect(vm.state.value.byBookId[b.id], info);
      verify(mockResolver.resolve(b.title, b.author)).called(1);

      await vm.resolveFor(b);
      verifyNoMoreInteractions(mockResolver);
    });
  });

  test('consumeEvent limpa o evento', () {
    vm.event.value = ShowSuccessSnackBar('ok');
    vm.consumeEvent();
    expect(vm.event.value, isNull);
  });
}
