import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_card.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_view_model.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/presentation/widgets/filter_choice_chip.dart';
import 'package:flutter/material.dart';

class AllBooksTab extends StatelessWidget {
  const AllBooksTab({super.key, required this.viewModel});
  final ExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ExplorerState>(
      valueListenable: viewModel.state,
      builder: (context, explorer, _) {
        final filtered = viewModel.allBooksFiltered();

        return ListView(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Sort by:', style: AppTextStyles.body1Bold),
                  const SizedBox(width: 8),
                  FilterChoiceChip(
                    selected: explorer.query.sort.runtimeType == SortByAZ,
                    label: 'A–Z',
                    onTap: () =>
                        viewModel.updateQuery(explorer.query.copyWith(sort: const SortByAZ())),
                  ),
                  FilterChoiceChip(
                    label: 'Newest',
                    selected: explorer.query.sort.runtimeType == SortByNewest,
                    onTap: () =>
                        viewModel.updateQuery(explorer.query.copyWith(sort: const SortByNewest())),
                  ),
                  FilterChoiceChip(
                    label: 'Oldest',
                    selected: explorer.query.sort.runtimeType == SortByOldest,
                    onTap: () =>
                        viewModel.updateQuery(explorer.query.copyWith(sort: const SortByOldest())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 160 / 280,
                ),
                itemBuilder: (context, i) {
                  final b = filtered[i];
                  final info = explorer.byBookId[b.id];
                  return BookCard.compact(
                    book: b,
                    info: info,
                    showPercentage: false,
                    showStars: false,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
