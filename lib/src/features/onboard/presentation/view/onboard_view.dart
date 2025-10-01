import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_button.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/onboard/presentation/view_model/onboard_view_model.dart';
import 'package:book_library/src/features/onboard/presentation/widgets/dots.dart';
import 'package:book_library/src/features/onboard/presentation/widgets/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardView extends StatefulWidget {
  const OnboardView({super.key, required this.viewModel});
  final OnboardViewModel viewModel;

  @override
  State<OnboardView> createState() => _OnboardViewState();
}

class _OnboardViewState extends State<OnboardView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    widget.viewModel.event.addListener(() {
      final event = widget.viewModel.event.value;
      if (event is NavigateTo) {
        if (mounted) context.goNamed(event.route);
      } else if (event is ShowErrorSnackBar) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(event.message)));
        }
      }
      widget.viewModel.consumeEvent();
    });
  }

  void onSkip() {
    widget.viewModel.completeOnboarding();
  }

  void onNext() {
    if (widget.viewModel.isLast) {
      widget.viewModel.completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Scaffold(
      appBar: AppBar(
        actions: [
          SkipButton(onPressed: onSkip),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: widget.viewModel.index,
          builder: (context, modelIndex, _) {
            return Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.viewModel.slides.length,
                    onPageChanged: widget.viewModel.setIndex,
                    itemBuilder: (context, index) {
                      final slide = widget.viewModel.slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(slide.asset, height: 220),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              slide.title,
                              style: AppTextStyles.h5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              slide.description,
                              style: AppTextStyles.body2Regular.copyWith(
                                color: colors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                Dots(count: widget.viewModel.slides.length, index: modelIndex),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ValueListenableBuilder<int>(
          valueListenable: widget.viewModel.index,
          builder: (context, index, _) {
            final isLast = index == widget.viewModel.slides.length - 1;
            return BookLibraryButton(
              text: isLast ? 'Get Started' : 'Next',
              textStyle: AppTextStyles.subtitle1Medium.copyWith(color: colors.textLight),
              onPressed: onNext,
            );
          },
        ),
      ),
    );
  }
}
