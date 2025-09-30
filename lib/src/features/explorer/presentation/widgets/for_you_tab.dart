import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_card.dart';
import 'package:book_library/src/features/books/presentation/widgets/highlight_book_card.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:book_library/src/features/explorer/presentation/view_model/explorer_view_model.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/explorer_skeleton.dart';
import 'package:flutter/material.dart';

class ForYouTab extends StatelessWidget {
  const ForYouTab({super.key, required this.viewModel});
  final ExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ExplorerState>(
      valueListenable: viewModel.state,
      builder: (context, explorer, _) {
        if (explorer.newReleases.isEmpty) {
          return const ExploreSkeleton();
        }

        return ListView(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Featured', style: AppTextStyles.h6),
            ),
            const SizedBox(height: 8),
            HighlightBookCard(
              book: explorer.newReleases[0],
              info: explorer.byBookId[explorer.newReleases[1].id],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('New Releases', style: AppTextStyles.h6),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: explorer.newReleases.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final b = explorer.newReleases[i];
                  final ExternalBookInfoEntity? info = explorer.byBookId[b.id];
                  return BookCard.compact(
                    book: b,
                    info: info,
                    showPercentage: false,
                    showStars: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Similar to your favorites', style: AppTextStyles.h6),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: explorer.similarToFavorites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final b = explorer.similarToFavorites[i];
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
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
