import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    Widget skeletonBox({
      double? width,
      double? height,
      BorderRadius? radius,
      EdgeInsetsGeometry? margin,
      BoxBorder? border,
    }) {
      final base = colors.tapEffect;
      final highlight = colors.tapEffect.withAlpha(200);

      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: base,
            borderRadius: radius ?? BorderRadius.circular(8),
            border: border,
          ),
        ),
      );
    }

    Widget chip() => skeletonBox(
      width: 90,
      height: 36,
      margin: const EdgeInsets.only(right: 12),
      radius: BorderRadius.circular(24),
      border: Border.all(color: colors.border),
    );

    Widget card() => Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeletonBox(height: 260, radius: BorderRadius.circular(12)),
          const SizedBox(height: 12),
          skeletonBox(height: 14, width: 160),
          const SizedBox(height: 8),
          skeletonBox(height: 12, width: 100),
        ],
      ),
    );

    return ListView(
      children: [
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(children: List.generate(5, (_) => chip())),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              skeletonBox(height: 28, width: 120, radius: BorderRadius.circular(6)),
              skeletonBox(height: 16, width: 60, radius: BorderRadius.circular(6)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 424,
          width: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, __) => card(),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: 3,
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              skeletonBox(height: 28, width: 120, radius: BorderRadius.circular(6)),
              const SizedBox(height: 8),
              skeletonBox(height: 14, width: 240, radius: BorderRadius.circular(6)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 424,
          width: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, __) => card(),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: 3,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
