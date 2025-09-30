import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class RatingBlock extends StatelessWidget {
  const RatingBlock({super.key, required this.avg, required this.reviewsLabel});
  final double avg;
  final String reviewsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < 4;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 28,
                color: colors.textPrimary,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to rate this book',
          style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              '${avg.toStringAsFixed(1)} • $reviewsLabel reviews',
              style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
