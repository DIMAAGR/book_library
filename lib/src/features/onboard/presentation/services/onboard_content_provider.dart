import 'package:book_library/src/core/constants/app_illustrations.dart';
import 'package:book_library/src/features/onboard/presentation/models/onboard_slide_ui.dart';

abstract class OnboardContentProvider {
  List<OnboardSlideUi> slides();
}

class OnboardContentStatic implements OnboardContentProvider {
  @override
  List<OnboardSlideUi> slides() => [
    const OnboardSlideUi(
      asset: AppIllustrations.bookReading,
      title: 'Discover your next favorite book',
      description: 'Explore thousands of titles and find the perfect story for you.',
    ),
    const OnboardSlideUi(
      asset: AppIllustrations.saveBooks,
      title: 'Save your favorite books',
      description: 'Mark books you love and access them anytime in your saved list.',
    ),
    const OnboardSlideUi(
      asset: AppIllustrations.focusedReading,
      title: 'Read with no distractions',
      description: 'Enjoy a clean, focused reading experience with adjustable themes and fonts.',
    ),
  ];
}
