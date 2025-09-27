import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_view_model.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_view_model_state.dart';
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
    test('emite SuccessState e realiza prefetch', () async {
      when(mockGetCategories.call()).thenAnswer((_) async => Right(categories));
      when(mockGetBooks.call()).thenAnswer((_) async => Right(books));
      when(mockResolver.prefetch(any)).thenAnswer((_) async {});

      await vm.load();

      expect(vm.state.value, isA<SuccessState<Failure, HomeData>>());
      final data = (vm.state.value as SuccessState<Failure, HomeData>).success;

      expect(data.activeCategoryId, categories.first.id);

      expect(data.library.length, books.length ~/ 2);
      expect(data.explore.length, books.length - data.library.length);

      verify(mockResolver.prefetch(any)).called(2);
      verifyNoMoreInteractions(mockResolver);
      expect(vm.event.value, isNull);
    });

    test('quando falha categorias -> ErrorState + ShowErrorSnackBar', () async {
      when(
        mockGetCategories.call(),
      ).thenAnswer((_) async => const Left(NetworkFailure('cats fail')));

      await vm.load();

      expect(vm.state.value, isA<ErrorState<Failure, HomeData>>());
      expect(vm.event.value, isA<ShowErrorSnackBar>());
      expect((vm.event.value as ShowErrorSnackBar).message, 'cats fail');

      verifyNever(mockGetBooks.call());
    });

    test('quando falha livros -> ErrorState + ShowErrorSnackBar', () async {
      when(mockGetCategories.call()).thenAnswer((_) async => Right(categories));
      when(mockGetBooks.call()).thenAnswer((_) async => const Left(NetworkFailure('books fail')));

      await vm.load();

      expect(vm.state.value, isA<ErrorState<Failure, HomeData>>());
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

    test('atualiza activeCategoryId e prefetch da library', () async {
      final before = (vm.state.value as SuccessState<Failure, HomeData>).success.activeCategoryId;

      vm.selectCategory(categories.last.id);

      final after = (vm.state.value as SuccessState<Failure, HomeData>).success.activeCategoryId;

      expect(before, isNot(equals(after)));
      expect(after, categories.last.id);
      verify(mockResolver.prefetch(any)).called(1);
    });

    test('não faz nada se escolher a mesma categoria', () async {
      final current = (vm.state.value as SuccessState<Failure, HomeData>).success.activeCategoryId!;
      vm.selectCategory(current);
      verifyNever(mockResolver.prefetch(any));
    });
  });

  group('resolveFor()', () {
    test('resolve e popula byBookId; evita chamadas repetidas', () async {
      final b = books.first;
      final info = const ExternalBookInfoEntity(
        title: 'X',
        description: 'desc',
        coverUrl: 'http://example.com/example.jpg',
        isbn13: '978...',
      );

      when(mockResolver.resolve(b.title, b.author)).thenAnswer((_) async => info);

      await vm.resolveFor(b);
      expect(vm.byBookId.value[b.id], info);
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
