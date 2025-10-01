import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:book_library/src/core/presentation/widgets/skeletons/book_library_compact_book_card_skeleton.dart';
import 'package:book_library/src/core/presentation/widgets/skeletons/book_library_highlight_book_card_skeleton.dart';
import 'package:book_library/src/core/presentation/widgets/skeletons/book_library_horizontal_row_skeleton.dart';
import 'package:book_library/src/core/presentation/widgets/skeletons/book_library_title_skeleton.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/horizontal_card_skeleton.dart';
import 'package:book_library/src/features/explorer/presentation/widgets/tab_skeleton.dart';
import 'package:flutter/material.dart';

class ExploreSkeleton extends StatelessWidget {
  const ExploreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabSkeleton(),
        Expanded(
          child: ListView(
            children: const [
              SizedBox(height: 16),
              BookLibraryTitleSkeleton(),
              SizedBox(height: 8),
              BookLibraryHighlightBookCardSkeleton(),
              SizedBox(height: 16),
              BookLibraryTitleSkeleton(),
              SizedBox(height: 8),
              HorizontalCardsSkeleton(count: 6, height: 280),
              SizedBox(height: 16),
              BookLibraryTitleSkeleton(),
              SizedBox(height: 8),
              HorizontalCardsSkeleton(count: 6, height: 280),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class ExplorePopularSkeleton extends StatelessWidget {
  const ExplorePopularSkeleton({super.key, this.count = 10});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const ShimmerBox(
            width: 160,
            height: 22,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          );
        }
        return const BookLibraryHorizontalRowSkeleton();
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: count + 1,
    );
  }
}

class ExploreAllBooksSkeleton extends StatelessWidget {
  const ExploreAllBooksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ShimmerBox(width: 70, height: 18, borderRadius: BorderRadius.all(Radius.circular(6))),
              SizedBox(width: 12),
              ShimmerBox(
                width: 48,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              SizedBox(width: 8),
              ShimmerBox(
                width: 70,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              SizedBox(width: 8),
              ShimmerBox(
                width: 60,
                height: 28,
                borderRadius: BorderRadius.all(Radius.circular(24)),
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
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 160 / 280,
            ),
            itemBuilder: (_, __) => const BookLibraryCompactBookCardSkeleton(),
          ),
        ),
      ],
    );
  }
}
