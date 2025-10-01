import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/launcher/presentation/view_model/launcher_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockGetOnboardingDoneUseCase mockGetDone;
  late LauncherViewModel viewModel;

  setUp(() {
    mockGetDone = MockGetOnboardingDoneUseCase();
    viewModel = LauncherViewModel(mockGetDone);
  });

  group('decide()', () {
    test('emite NavigateTo(/home) quando isDone = true', () async {
      when(mockGetDone()).thenAnswer((_) async => const Right(true));

      await viewModel.decide();

      expect(viewModel.state.value, isA<SuccessState<Failure, bool>>());
      expect((viewModel.state.value as SuccessState).success, true);

      expect(viewModel.event.value, isA<NavigateTo>());
      expect((viewModel.event.value as NavigateTo).route, AppRoutes.home);

      verify(mockGetDone()).called(1);
      verifyNoMoreInteractions(mockGetDone);
    });

    test('emite NavigateTo(/onboard) quando isDone = false', () async {
      when(mockGetDone()).thenAnswer((_) async => const Right(false));

      await viewModel.decide();

      expect(viewModel.state.value, isA<SuccessState<Failure, bool>>());
      expect((viewModel.state.value as SuccessState).success, false);

      expect(viewModel.event.value, isA<NavigateTo>());
      expect((viewModel.event.value as NavigateTo).route, AppRoutes.onboard);

      verify(mockGetDone()).called(1);
      verifyNoMoreInteractions(mockGetDone);
    });

    test('emite ShowErrorSnackBar quando falha', () async {
      when(mockGetDone()).thenAnswer((_) async => const Left(StorageFailure('boom')));

      await viewModel.decide();

      expect(viewModel.state.value, isA<ErrorState<Failure, bool>>());
      final err = (viewModel.state.value as ErrorState).error as StorageFailure;
      expect(err.message, 'boom');

      expect(viewModel.event.value, isA<ShowErrorSnackBar>());
      expect((viewModel.event.value as ShowErrorSnackBar).message, 'boom');

      verify(mockGetDone()).called(1);
      verifyNoMoreInteractions(mockGetDone);
    });
  });
}
