import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:flutter/material.dart';

class BookLibraryHorizontalRowSkeleton extends StatelessWidget {
  const BookLibraryHorizontalRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 64, height: 86, borderRadius: BorderRadius.all(Radius.circular(12))),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 200, height: 16),
                SizedBox(height: 8),
                ShimmerBox(width: 160, height: 14),
                SizedBox(height: 10),
                ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
        ],
      ),
    );
  }
}
