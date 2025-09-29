import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/views/offiline_view.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/search/presentation/view_model/search_view_model.dart';
import 'package:book_library/src/features/search/presentation/widgets/search_app_bar.dart';
import 'package:book_library/src/features/search/presentation/widgets/search_skeleton.dart';
import 'package:book_library/src/features/search/presentation/widgets/search_sliver_item_list.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.viewModel});
  final SearchViewModel viewModel;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final SearchViewModel viewModel = widget.viewModel;
  final _controller = TextEditingController();
  VoidCallback? _eventL;

  @override
  void initState() {
    super.initState();
    viewModel.init();
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
    _controller.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Scaffold(
      appBar: SearchAppBar(
        controller: _controller,
        onTextChanged: viewModel.onTextChanged,
        onClear: viewModel.clearAllFilterSelection,
        onApply: viewModel.applyCurrentFilterSelection,
        range: viewModel.range,
        sort: viewModel.sort,
      ),
      backgroundColor: c.background,
      body: ValueListenableBuilder<ViewModelState<dynamic, List<BookEntity>>>(
        valueListenable: viewModel.state,
        builder: (_, st, __) {
          if (st is LoadingState) {
            return const CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 8)),
                SearchSkeletonSliverList(count: 10),
              ],
            );
          }

          if (st is ErrorState) {
            return OfflineView(
              onRetry: () {
                viewModel.init();
              },
              onOpenSettings: () {},
            );
          }

          if (st is SuccessState<dynamic, List<BookEntity>>) {
            final items = st.success;

            return CustomScrollView(
              slivers: [
                if (items.isEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 64)),
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 56),
                          SizedBox(height: 8),
                          Text('No books match your filters'),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 64)),
                ] else ...[
                  SearchItemSliverList(
                    hasInfoFor: viewModel.hasInfoFor,
                    resolveFor: viewModel.resolveFor,
                    byBookId: viewModel.byBookId,
                    favorites: viewModel.favorites,
                    toggleFavorite: viewModel.toggleFavorite,
                    items: items,
                  ),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
