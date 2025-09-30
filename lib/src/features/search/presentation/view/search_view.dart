import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/views/offline_view.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/features/search/presentation/view_model/search_state_object.dart';
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
  late final SearchViewModel vm = widget.viewModel;
  final _controller = TextEditingController();
  VoidCallback? _eventL;

  @override
  void initState() {
    super.initState();
    vm.init();
    _eventL = () {
      final e = vm.event.value;
      if (e == null || !mounted) return;
      if (e is ShowErrorSnackBar) {
        BookLibrarySnackBars.errorSnackBar(context, e.message);
      } else if (e is ShowSuccessSnackBar) {
        BookLibrarySnackBars.successSnackbar(context, e.message);
      } else if (e is ShowSnackBar) {
        BookLibrarySnackBars.informativeSnackBar(context, e.message);
      }
      vm.consumeEvent();
    };
    vm.event.addListener(_eventL!);
  }

  @override
  void dispose() {
    if (_eventL != null) vm.event.removeListener(_eventL!);
    _controller.dispose();
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SearchStateObject>(
      valueListenable: vm.state,
      builder: (_, s, __) {
        if (_controller.text != s.text) {
          _controller.value = TextEditingValue(
            text: s.text,
            selection: TextSelection.collapsed(offset: s.text.length),
          );
        }

        return Scaffold(
          appBar: SearchAppBar(
            controller: _controller,
            onTextChanged: vm.onTextChanged,
            currentRange: s.filters.range,
            currentSort: s.filters.sort,
            onApplyFilters: (range, sort) {
              vm.setRange(range);
              vm.setSort(sort);
            },
            onClearFilters: vm.clearAllFilterSelection,
          ),
          backgroundColor: Theme.of(context).colors.background,
          body: s.state.fold(
            onError: (f) => OfflineView(onRetry: vm.init, onOpenSettings: () {}),
            onInitial: () =>
                const CustomScrollView(slivers: [SliverToBoxAdapter(child: SizedBox(height: 8))]),
            onLoading: () => const CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 8)),
                SearchSkeletonSliverList(count: 10),
              ],
            ),
            onSuccess: (payload) {
              final items = payload.items;
              if (items.isEmpty) {
                return const CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: 64)),
                    SliverToBoxAdapter(
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
                    SliverToBoxAdapter(child: SizedBox(height: 64)),
                  ],
                );
              }
              return CustomScrollView(
                slivers: [
                  SearchItemSliverList(
                    hasInfoFor: vm.hasInfoFor,
                    resolveFor: vm.resolveCoverIfMissing,
                    byBookId: ValueNotifier(s.byBookId),
                    favorites: ValueNotifier(s.favorites),
                    toggleFavorite: vm.toggleFavorite,
                    items: items,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
