import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:flutter/material.dart';

class BookLibraryHighlightBookCardSkeleton extends StatelessWidget {
  const BookLibraryHighlightBookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const ShimmerBox(width: 96, height: 128),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 200, height: 18),
                  SizedBox(height: 8),
                  ShimmerBox(width: 140, height: 14),
                  SizedBox(height: 12),
                  ShimmerBox(
                    width: 100,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
