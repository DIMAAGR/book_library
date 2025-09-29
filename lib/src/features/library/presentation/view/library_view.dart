import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_app_bar.dart';
import 'package:book_library/src/core/presentation/widgets/category_chips.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
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
            if (st is LoadingState) return const LibrarySkeleton();
            if (st is ErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 56, color: colors.textSecondary),
                      const SizedBox(height: 12),
                      Text('Something went wrong', style: AppTextStyles.h6),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again.',
                        style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: viewModel.load, child: const Text('Retry')),
                    ],
                  ),
                ),
              );
            }

            final items = viewModel.state.value.items;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CategoryChips(
                      items: viewModel.state.value.categories,
                      activeId: viewModel.state.value.activeCategoryId,
                      onTap: viewModel.selectCategory,
                    ),
                  ),
                  ValueListenableBuilder<LibraryStateObject>(
                    valueListenable: viewModel.state,
                    builder: (context, infos, __) {
                      return SliverToBoxAdapter(
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
                                      final info = infos.byBookId[book.id];

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
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
