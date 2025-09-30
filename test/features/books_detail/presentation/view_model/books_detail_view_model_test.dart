import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:book_library/src/features/books_details/presentation/view_model/books_details_state_object.dart';
import 'package:book_library/src/features/books_details/presentation/view_model/books_details_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockExternalBookInfoResolver mockResolver;
  late MockIsFavoriteUseCase mockIsFavorite;
  late MockToggleFavoriteUseCase mockToggleFavorite;
  late MockIsReadingUseCase mockIsReading;
  late MockToggleReadingUseCase mockToggleReading;
  late MockGetProgressUseCase mockGetProgress;
  late MockSetProgressUseCase mockSetProgress;
  late MockShareService mockShare;
  late MockGetAllBooksUseCase mockGetAll;

  late BookDetailsViewModel vm;

  const book = BookEntity(id: '1', title: 'Clean Code', author: 'Robert C. Martin');
  const b2 = BookEntity(id: '2', title: 'Clean Architecture', author: 'Robert C. Martin');
  const b3 = BookEntity(
    id: '3',
    title: 'Working Effectively with Legacy Code',
    author: 'Michael Feathers',
  );

  setUp(() {
    mockResolver = MockExternalBookInfoResolver();
    mockIsFavorite = MockIsFavoriteUseCase();
    mockToggleFavorite = MockToggleFavoriteUseCase();
    mockIsReading = MockIsReadingUseCase();
    mockToggleReading = MockToggleReadingUseCase();
    mockGetProgress = MockGetProgressUseCase();
    mockSetProgress = MockSetProgressUseCase();
    mockShare = MockShareService();
    mockGetAll = MockGetAllBooksUseCase();

    vm = BookDetailsViewModel(
      mockResolver,
      mockIsFavorite,
      mockToggleFavorite,
      mockIsReading,
      mockToggleReading,
      mockGetProgress,
      mockSetProgress,
      mockShare,
      mockGetAll,
    );
  });

  group('BookDetailsViewModel init/load', () {
    test('carrega flags, progresso, similar e info', () async {
      when(mockResolver.resolve(book.title, book.author)).thenAnswer(
        (_) async =>
            const ExternalBookInfoEntity(title: 'Clean Code', isbn13: '123', coverUrl: 'u'),
      );
      when(mockIsFavorite(book.id)).thenAnswer((_) async => const Right(true));
      when(mockIsReading(book.id)).thenAnswer((_) async => const Right(false));
      when(mockGetProgress(book.id)).thenAnswer((_) async => const Right(0));
      when(mockGetAll()).thenAnswer((_) async => const Right([book, b2, b3]));

      vm.init(book);
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final st = vm.state.value.state;
      expect(st, isA<SuccessState<Failure, BookDetailsPayload>>());
    });

    test('continua mesmo se algum Either vier com Left', () async {
      when(mockResolver.resolve(book.title, book.author)).thenAnswer((_) async => null);
      when(mockIsFavorite(book.id)).thenAnswer((_) async => Left(StorageFailure('x')));
      when(mockIsReading(book.id)).thenAnswer((_) async => Left(StorageFailure('y')));
      when(mockGetProgress(book.id)).thenAnswer((_) async => Left(StorageFailure('z')));
      when(mockGetAll()).thenAnswer((_) async => const Right([book]));

      vm.init(book);
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final st = vm.state.value.state;
      expect(st, isA<SuccessState<Failure, BookDetailsPayload>>());
      expect(vm.state.value.isFavorite, false);
      expect(vm.state.value.isReading, false);
      expect(vm.state.value.progress, 0);
    });
  });

  group('resolveFor', () {
    test('atualiza byBookId uma única vez', () async {
      when(
        mockResolver.resolve(book.title, book.author),
      ).thenAnswer((_) async => const ExternalBookInfoEntity(title: 'Clean Code'));

      await vm.resolveFor(book);
      await vm.resolveFor(book);

      expect(vm.state.value.byBookId.containsKey(book.id), true);
      verify(mockResolver.resolve(book.title, book.author)).called(1);
    });
  });

  group('shareCurrent', () {
    test('compartilha quando há book no estado', () async {
      vm.state.value = vm.state.value.copyWith(book: SuccessState<Failure, BookEntity>(book));

      when(mockShare.shareText(any, subject: anyNamed('subject'))).thenAnswer((_) async {});

      await vm.shareCurrent();

      verify(
        mockShare.shareText('“${book.title}” by ${book.author}', subject: 'Check this book'),
      ).called(1);
    });
  });

  group('toggleFavorite', () {
    test('inverte flag local após sucesso do use case', () async {
      vm.state.value = vm.state.value.copyWith(book: SuccessState<Failure, BookEntity>(book));
      when(mockToggleFavorite(book.id)).thenAnswer((_) async => const Right(<String>{}));

      final initial = vm.state.value.isFavorite;
      await vm.toggleFavorite();
      expect(vm.state.value.isFavorite, !initial);
    });
  });

  group('toggleReading', () {
    test('continua mesmo se algum Either vier com Left', () async {
      when(mockResolver.resolve(book.title, book.author)).thenAnswer((_) async => null);
      when(mockIsFavorite(book.id)).thenAnswer((_) async => const Left(StorageFailure('x')));
      when(mockIsReading(book.id)).thenAnswer((_) async => const Left(StorageFailure('y')));
      when(mockGetProgress(book.id)).thenAnswer((_) async => const Left(StorageFailure('z')));
      when(mockGetAll()).thenAnswer((_) async => const Right([book]));

      vm.init(book);
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final st = vm.state.value.state;
      expect(st, isA<SuccessState<Failure, BookDetailsPayload>>());
      expect(vm.state.value.isFavorite, false);
      expect(vm.state.value.isReading, false);
      expect(vm.state.value.progress, 0);
    });

    test('desliga leitura não chama setProgress', () async {
      vm.state.value = vm.state.value.copyWith(
        book: SuccessState<Failure, BookEntity>(book),
        progress: 50,
      );

      when(mockToggleReading(book.id)).thenAnswer((_) async => const Right(false));

      await vm.toggleReading();

      expect(vm.state.value.isReading, false);
      verifyNever(mockSetProgress(any, any));
    });
  });
}
