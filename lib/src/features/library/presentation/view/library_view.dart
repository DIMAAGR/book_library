import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/views/offiline_view.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_app_bar.dart';
import 'package:book_library/src/core/presentation/widgets/category_chips.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_card.dart';
import 'package:book_library/src/features/library/presentation/view_model/library_state_object.dart';
import 'package:book_library/src/features/library/presentation/view_model/library_view_model.dart';
import 'package:book_library/src/features/library/presentation/widgets/library_skeleton.dart';
import 'package:flutter/material.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key, required this.viewModel});
  final LibraryViewModel viewModel;

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  late final LibraryViewModel viewModel = widget.viewModel;
  VoidCallback? _eventL;

  @override
  void initState() {
    super.initState();
    viewModel.load();

    _eventL = () {
      final event = viewModel.event.value;
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
    viewModel.event.addListener(_eventL!);
  }

  @override
  void dispose() {
    if (_eventL != null) viewModel.event.removeListener(_eventL!);
    super.dispose();
  }

  Future<void> _onRefresh() => viewModel.load();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Scaffold(
      appBar: const BookLibraryAppBar(
        title: 'Library',
        showMenu: false,
        showSearch: true,
        showSettings: false,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<LibraryStateObject>(
          valueListenable: viewModel.state,
          builder: (context, st, _) {
            return st.state.fold(
              onInitial: () => const LibrarySkeleton(),
              onLoading: () => const LibrarySkeleton(),
              onError: (f) => OfflineView(onRetry: viewModel.load, onOpenSettings: () {}),
              onSuccess: (payload) {
                final items = payload.items;
                final categories = payload.categories;
                final activeId = payload.activeCategoryId;

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: CategoryChips(
                          items: categories,
                          activeId: activeId,
                          onTap: viewModel.selectCategory,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth >= 700 ? 3 : 2;
                            const hSpacing = 16.0;

                            final cellWidth = (constraints.maxWidth - 64) / cols;
                            const coverAspect = 3 / 4;
                            final coverHeight = cellWidth / coverAspect;
                            final cellHeight = coverHeight + 128;
                            final ratio = ((constraints.maxWidth - 64) / cols) / cellHeight;

                            return CustomScrollView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                                  sliver: SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      mainAxisSpacing: hSpacing,
                                      crossAxisSpacing: hSpacing,
                                      childAspectRatio: ratio,
                                    ),
                                    delegate: SliverChildBuilderDelegate((context, index) {
                                      final book = items[index];
                                      final info = st.byBookId[book.id];

                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        viewModel.resolveFor(book);
                                      });

                                      return BookCard(
                                        book: book,
                                        info: info,
                                        showStars: true,
                                        showPercentage: true,
                                        coverAspectRatio: coverAspect,
                                        coverHeight: null,
                                      );
                                    }, childCount: items.length),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      backgroundColor: colors.background,
    );
  }
}
