import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:flutter/material.dart';

class BookLibraryCompactBookCardSkeleton extends StatelessWidget {
  const BookLibraryCompactBookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 200, borderRadius: BorderRadius.all(Radius.circular(12))),
          SizedBox(height: 12),
          ShimmerBox(height: 14, width: 140),
          SizedBox(height: 8),
          ShimmerBox(height: 12, width: 100),
        ],
      ),
    );
  }
}
