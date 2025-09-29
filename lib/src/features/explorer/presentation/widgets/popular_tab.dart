import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/presentation/widgets/horizontal_book_card.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_view_model.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/explorer_skeleton.dart';
import 'package:flutter/material.dart';

class PopularTab extends StatelessWidget {
  const PopularTab({super.key, required this.viewModel});
  final ExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ExplorerState>(
      valueListenable: viewModel.state,
      builder: (context, explorer, _) {
        if (explorer.popularTop10.isEmpty) {
          return const ExplorePopularSkeleton();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: explorer.popularTop10.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Top 10 Overall', style: AppTextStyles.h6);
            }
            final i = index - 1;
            final b = explorer.popularTop10[i];
            final info = explorer.byBookId[b.id];
            final isFavorite = explorer.favorites.contains(b.id);

            return HorizontalBookCard(
              book: b,
              info: info,
              isFavorite: isFavorite,
              onFavoriteToggle: () => viewModel.toggleFavorite(b.id),
              onTap: () {},
              showRank: true,
              rank: i + 1,
            );
          },
        );
      },
    );
  }
}
