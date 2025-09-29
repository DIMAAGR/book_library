import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.margin,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    final base = c.tapEffect;
    final highlight = c.tapEffect.withAlpha(200);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(color: base, borderRadius: borderRadius),
      ),
    );
  }
}

class ShimmerChip extends StatelessWidget {
  const ShimmerChip({super.key, this.width = 90});
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ShimmerBox(width: width, height: 36, borderRadius: BorderRadius.circular(24)),
    );
  }
}
