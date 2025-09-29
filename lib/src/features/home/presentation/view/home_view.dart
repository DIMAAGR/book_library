import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/presentation/views/offiline_view.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_app_bar.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_bottom_navigation_bar.dart';
import 'package:book_library/src/core/presentation/widgets/category_chips.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_state_object.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_view_model.dart';
import 'package:book_library/src/features/home/presentation/widgets/home_skeleton.dart';
import 'package:book_library/src/features/home/presentation/widgets/horizontal_books_list.dart';
import 'package:book_library/src/features/home/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.viewModel});
  final HomeViewModel viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final VoidCallback _eventDisposer;
  HomeViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _eventDisposer = _bindUiEvents();
    viewModel.load();
  }

  @override
  void dispose() {
    _eventDisposer();
    super.dispose();
  }

  VoidCallback _bindUiEvents() {
    void listener() {
      final event = viewModel.event.value;
      if (event == null || !mounted) return;

      if (event is ShowErrorSnackBar) {
        BookLibrarySnackBars.errorSnackBar(context, event.message);
      } else if (event is ShowSuccessSnackBar) {
        BookLibrarySnackBars.successSnackbar(context, event.message);
      } else if (event is ShowSnackBar) {
        BookLibrarySnackBars.informativeSnackBar(context, event.message);
      } else if (event is NavigateTo) {
        context.goNamed(event.route);
      } else if (event is Pop) {
        Navigator.of(context).maybePop();
      }

      viewModel.consumeEvent();
    }

    viewModel.event.addListener(listener);
    return () => viewModel.event.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BookLibraryAppBar(
        title: 'Library',
        showMenu: true,
        showSearch: true,
        showSettings: true,
      ),
      bottomNavigationBar: const BookLibraryBottomNavigationBar(),
      body: SafeArea(
        child: ValueListenableBuilder<HomeStateObject>(
          valueListenable: viewModel.state,
          builder: (context, home, _) {
            final s = home.state;

            if (s is LoadingState<Failure, HomePayload>) {
              return const HomeSkeleton();
            }

            if (s is ErrorState<Failure, HomePayload>) {
              return OfflineView(
                onRetry: () => viewModel.load(),
                onOpenSettings: () => context.goNamed(AppRoutes.settings),
              );
            }

            if (s is SuccessState<Failure, HomePayload>) {
              final data = s.success;

              return ListView(
                children: [
                  const SizedBox(height: 8),
                  CategoryChips(
                    items: data.categories,
                    activeId: data.activeCategoryId,
                    onTap: viewModel.selectCategory,
                  ),
                  SectionHeader(
                    title: 'Library',
                    action: 'See all',
                    onTap: () => context.pushNamed(AppRoutes.library),
                  ),
                  HorizontalBooksList(
                    list: home.library,
                    resolveFor: viewModel.resolveFor,
                    homeState: viewModel.state,
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: 'Explore',
                    subtitle: 'Our store has more than 390+ books.',
                  ),
                  HorizontalBooksList(
                    list: home.explore,
                    resolveFor: viewModel.resolveFor,
                    homeState: viewModel.state,
                    showStars: false,
                    showPercentage: false,
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
