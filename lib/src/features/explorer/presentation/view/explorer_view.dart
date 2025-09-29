import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/views/offiline_view.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_app_bar.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_bottom_navigation_bar.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_view_model.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/all_books_tab.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/explorer_skeleton.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/for_you_tab.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/popular_tab.dart';
import 'package:flutter/material.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key, required this.viewModel});
  final ExploreViewModel viewModel;

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> with SingleTickerProviderStateMixin {
  late final ExploreViewModel viewModel = widget.viewModel;
  late final TabController tabs;
  VoidCallback? _eventListener;

  @override
  void initState() {
    super.initState();

    tabs = TabController(length: 3, vsync: this);

    _bindUiEvents();
    viewModel.init();
  }

  void _bindUiEvents() {
    _eventListener = () {
      final event = viewModel.events.value;
      if (event == null || !mounted) return;
      if (event is ShowErrorSnackBar) {
        BookLibrarySnackBars.errorSnackBar(context, event.message);
      } else if (event is ShowSuccessSnackBar) {
        BookLibrarySnackBars.successSnackbar(context, event.message);
      } else if (event is ShowSnackBar) {
        BookLibrarySnackBars.informativeSnackBar(context, event.message);
      }
      viewModel.consumeEvent();
    };
    viewModel.events.addListener(_eventListener!);
  }

  @override
  void dispose() {
    if (_eventListener != null) viewModel.events.removeListener(_eventListener!);
    tabs.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Scaffold(
      appBar: const BookLibraryAppBar(title: 'Explore', showSearch: true, showMenu: true),
      bottomNavigationBar: const BookLibraryBottomNavigationBar(),
      backgroundColor: colors.background,
      body: SafeArea(
        child: ValueListenableBuilder<ExplorerState>(
          valueListenable: viewModel.state,
          builder: (context, explorer, _) {
            final st = explorer.state;

            if (st is LoadingState<Failure, List<BookEntity>>) {
              return const ExploreSkeleton();
            }

            if (st is ErrorState<Failure, List<BookEntity>>) {
              return OfflineView(onRetry: viewModel.init, onOpenSettings: () {});
            }

            return Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: tabs,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    labelColor: colors.textPrimary,
                    unselectedLabelColor: colors.textSecondary,
                    indicatorColor: colors.textPrimary,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'For You'),
                      Tab(text: 'Popular'),
                      Tab(text: 'All Books'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    controller: tabs,
                    children: [
                      ForYouTab(viewModel: viewModel),
                      PopularTab(viewModel: viewModel),
                      AllBooksTab(viewModel: viewModel),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
