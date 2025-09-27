import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/features/onboard/domain/use_cases/set_onboarding_done_use_case.dart';
import 'package:book_library/src/features/onboard/presentation/models/onboard_slide_ui.dart';
import 'package:book_library/src/features/onboard/presentation/services/onboard_content_provider.dart';
import 'package:flutter/widgets.dart';

class OnboardViewModel {
  OnboardViewModel(this.content, this._setOnboardingDoneUseCase) : slides = content.slides();

  final SetOnboardingDoneUseCase _setOnboardingDoneUseCase;
  final OnboardContentProvider content;
  final List<OnboardSlideUi> slides;

  ValueNotifier<int> index = ValueNotifier(0);
  ValueNotifier<UiEvent?> event = ValueNotifier(null);

  void setIndex(int i) {
    index.value = i;
  }

  Future<void> completeOnboarding() async {
    final failureOrSuccess = await _setOnboardingDoneUseCase(true);

    event.value = failureOrSuccess.fold(
      (failure) => ShowErrorSnackBar(failure.message),
      (_) => NavigateTo(AppRoutes.home),
    );
  }

  void consumeEvent() {
    event.value = null;
  }

  bool get isLast => index.value == slides.length - 1;
}
