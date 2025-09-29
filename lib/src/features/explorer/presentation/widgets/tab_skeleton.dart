import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:flutter/material.dart';

class TabSkeleton extends StatelessWidget {
  const TabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: kToolbarHeight - 16,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: const [
              ShimmerBox(width: 80, height: 14),
              ShimmerBox(width: 90, height: 14, margin: EdgeInsets.only(left: 24)),
              ShimmerBox(width: 100, height: 14, margin: EdgeInsets.only(left: 24)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: c.border),
      ],
    );
  }
}
