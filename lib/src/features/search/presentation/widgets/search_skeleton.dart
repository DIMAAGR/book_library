import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final base = colors.tapEffect;
    final highlight = colors.tapEffect.withAlpha(200);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: base, borderRadius: borderRadius),
      ),
    );
  }
}

class _HorizontalRowSkeleton extends StatelessWidget {
  const _HorizontalRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const _ShimmerBox(width: 64, height: 86),
          ),
          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: 180, height: 16),
                SizedBox(height: 8),
                _ShimmerBox(width: 140, height: 14),
                SizedBox(height: 10),
                _ShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),

          const _ShimmerBox(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}

class SearchSkeletonSliverList extends StatelessWidget {
  const SearchSkeletonSliverList({
    super.key,
    this.count = 8,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 20),
    this.itemSpacing = 12,
  });

  final int count;
  final EdgeInsets padding;
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverList.separated(
        itemBuilder: (_, __) => const _HorizontalRowSkeleton(),
        separatorBuilder: (_, __) => SizedBox(height: itemSpacing),
        itemCount: count,
      ),
    );
  }
}

class SearchSkeletonList extends StatelessWidget {
  const SearchSkeletonList({
    super.key,
    this.count = 8,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 20),
    this.itemSpacing = 12,
  });

  final int count;
  final EdgeInsets padding;
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemBuilder: (_, __) => const _HorizontalRowSkeleton(),
      separatorBuilder: (_, __) => SizedBox(height: itemSpacing),
      itemCount: count,
    );
  }
}
