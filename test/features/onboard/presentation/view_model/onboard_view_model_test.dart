import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/features/onboard/presentation/models/onboard_slide_ui.dart';
import 'package:book_library/src/features/onboard/presentation/view_model/onboard_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.mocks.mocks.dart';

void main() {
  late MockSetOnboardingDoneUseCase mockSetDone;
  late MockOnboardContentProvider mockContent;
  late OnboardViewModel viewModel;

  final slides = [
    const OnboardSlideUi(asset: 'a.png', title: 't1', description: 'd1'),
    const OnboardSlideUi(asset: 'b.png', title: 't2', description: 'd2'),
  ];

  setUp(() {
    mockSetDone = MockSetOnboardingDoneUseCase();
    mockContent = MockOnboardContentProvider();
    when(mockContent.slides()).thenReturn(slides);

    viewModel = OnboardViewModel(mockContent, mockSetDone);
  });

  group('setIndex', () {
    test('atualiza index corretamente', () {
      viewModel.setIndex(1);
      expect(viewModel.index.value, 1);
    });

    test('isLast retorna true no último slide', () {
      viewModel.setIndex(slides.length - 1);
      expect(viewModel.isLast, true);
    });
  });

  group('completeOnboarding', () {
    test('emite NavigateTo quando sucesso', () async {
      when(mockSetDone.call(true)).thenAnswer((_) async => const Right(unit));

      await viewModel.completeOnboarding();

      expect(viewModel.event.value, isA<NavigateTo>());
      expect((viewModel.event.value as NavigateTo).route, AppRoutes.home);
    });

    test('emite ShowErrorSnackBar quando falha', () async {
      when(mockSetDone.call(true)).thenAnswer((_) async => const Left(StorageFailure('boom')));

      await viewModel.completeOnboarding();

      expect(viewModel.event.value, isA<ShowErrorSnackBar>());
      expect((viewModel.event.value as ShowErrorSnackBar).message, 'boom');
    });
  });
}
