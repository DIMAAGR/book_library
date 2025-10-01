import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:flutter/material.dart';

class BookDetailsSkeleton extends StatelessWidget {
  const BookDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;

    Widget cardBox({required Widget child, EdgeInsetsGeometry? padding}) => Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: child,
    );

    Widget chip() => Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: const ShimmerBox(
        width: 56,
        height: 16,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );

    Widget compactCard() => Container(
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cardBox(
            child: const ShimmerBox(
              height: 260,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          cardBox(
            child: const ShimmerBox(
              height: 22,
              width: 240,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),
          cardBox(
            child: const ShimmerBox(
              height: 16,
              width: 160,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),
          cardBox(
            child: const ShimmerBox(
              height: 14,
              width: 180,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),

          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip(),
                const SizedBox(width: 12),
                chip(),
                const SizedBox(width: 12),
                chip(),
                const SizedBox(width: 12),
                chip(),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: cardBox(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Center(
                    child: ShimmerBox(
                      height: 18,
                      width: 140,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: const Center(
                  child: ShimmerBox(
                    height: 20,
                    width: 20,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          cardBox(
            child: const ShimmerBox(
              height: 18,
              width: 160,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),

          cardBox(
            child: const ShimmerBox(height: 12, borderRadius: BorderRadius.all(Radius.circular(6))),
          ),
          const SizedBox(height: 6),
          cardBox(
            child: const ShimmerBox(
              height: 12,
              width: 300,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 6),
          cardBox(
            child: const ShimmerBox(
              height: 12,
              width: 260,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),

          const SizedBox(height: 16),

          cardBox(
            child: const ShimmerBox(
              height: 18,
              width: 180,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => compactCard(),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }
}
