import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/get_onboarding_done_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

class LauncherViewModel {
  LauncherViewModel(this._getOnboardingDone);
  final GetOnboardingDoneUseCase _getOnboardingDone;

  final ValueNotifier<ViewModelState<Failure, bool>> state =
      ValueNotifier<ViewModelState<Failure, bool>>(InitialState());

  final ValueNotifier<UiEvent?> event = ValueNotifier<UiEvent?>(null);

  Future<void> decide() async {
    state.value = LoadingState();
    final Either<Failure, bool> result = await _getOnboardingDone();

    result.fold(
      (failure) {
        state.value = ErrorState(failure);
        event.value = ShowErrorSnackBar(failure.message);
      },
      (isDone) async {
        state.value = SuccessState(isDone);
        event.value = NavigateTo(isDone ? AppRoutes.home : AppRoutes.onboard);
      },
    );
  }
}
