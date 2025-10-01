import 'package:book_library/src/core/failures/failures.dart';
import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/views/offline_view.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_app_bar.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_bottom_navigation_bar.dart';
import 'package:book_library/src/core/presentation/widgets/snackbars.dart';
import 'package:book_library/src/core/state/ui_event.dart';
import 'package:book_library/src/core/state/view_model_state.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/presentation/widgets/horizontal_book_card.dart';
import 'package:book_library/src/features/favorites/presentation/view_model/favorites_state_object.dart';
import 'package:book_library/src/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:book_library/src/features/favorites/presentation/widgets/favorites_skeleton.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/presentation/widgets/filter_choice_chip.dart';
import 'package:flutter/material.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key, required this.viewModel});
  final FavoritesViewModel viewModel;

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late final FavoritesViewModel vm = widget.viewModel;
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
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;

    return Scaffold(
      appBar: const BookLibraryAppBar(title: 'Saved', showSearch: true),
      bottomNavigationBar: const BookLibraryBottomNavigationBar(),
      backgroundColor: c.background,
      body: SafeArea(
        child: ValueListenableBuilder<FavoritesStateObject>(
          valueListenable: vm.state,
          builder: (_, s, __) {
            final st = s.state;

            if (st is LoadingState<Failure, List>) return const FavoritesSkeleton();

            if (st is ErrorState<Failure, List>) {
              return OfflineView(onRetry: vm.init, onOpenSettings: () {});
            }

            if (s.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 56, color: c.textSecondary),
                    const SizedBox(height: 8),
                    Text('No favorites yet', style: AppTextStyles.h6),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the heart icon on a book to save it here.',
                      style: AppTextStyles.body2Regular.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Sort by:', style: AppTextStyles.body1Bold),
                    ),
                    const SizedBox(width: 8),
                    FilterChoiceChip(
                      label: 'A–Z',
                      selected: s.sort.runtimeType == SortByAZ,
                      onTap: () => vm.changeSort(const SortByAZ()),
                    ),
                    FilterChoiceChip(
                      label: 'Newest',
                      selected: s.sort.runtimeType == SortByNewest,
                      onTap: () => vm.changeSort(const SortByNewest()),
                    ),
                    FilterChoiceChip(
                      label: 'Oldest',
                      selected: s.sort.runtimeType == SortByOldest,
                      onTap: () => vm.changeSort(const SortByOldest()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: s.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final b = s.items[i];
                    final info = s.byBookId[b.id];
                    final isFav = s.favorites.contains(b.id);
                    return HorizontalBookCard(
                      book: b,
                      info: info,
                      isFavorite: isFav,
                      onFavoriteToggle: () => vm.onToggleFavorite(b.id),
                      showRank: false,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
