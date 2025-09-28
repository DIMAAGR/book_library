import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final base = colors.tapEffect;
    final highlight = colors.tapEffect.withAlpha(200);

    Widget block({double? w, double? h, BorderRadius? r, EdgeInsets? m}) {
      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          width: w,
          height: h,
          margin: m,
          decoration: BoxDecoration(
            color: base,
            borderRadius: r ?? BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(
                5,
                (_) => block(
                  w: 90,
                  h: 36,
                  r: BorderRadius.circular(24),
                  m: const EdgeInsets.only(right: 12),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, _) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    block(h: 180, r: BorderRadius.circular(12)),
                    const SizedBox(height: 12),
                    block(h: 14, w: 160),
                    const SizedBox(height: 8),
                    block(h: 12, w: 100),
                  ],
                ),
              ),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
