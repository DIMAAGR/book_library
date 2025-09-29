import 'package:book_library/src/core/presentation/widgets/skeletons/book_library_compact_book_card_skeleton.dart';
import 'package:flutter/material.dart';

class HorizontalCardsSkeleton extends StatelessWidget {
  const HorizontalCardsSkeleton({super.key, this.count = 6, this.height = 280});
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const BookLibraryCompactBookCardSkeleton(),
      ),
    );
  }
}
