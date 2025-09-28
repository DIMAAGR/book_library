import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_cover_placeholder.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.info,
    this.onTap,
    required this.showPercentage,
    required this.showStars,
    this.percentage = 50,
    this.coverAspectRatio = 3 / 4,
    this.coverHeight,
  });

  final BookEntity book;
  final ExternalBookInfoEntity? info;
  final VoidCallback? onTap;
  final int percentage;
  final bool showPercentage;
  final bool showStars;
  final double coverAspectRatio;
  final double? coverHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final coverUrl = info?.coverUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: coverHeight,
              child: AspectRatio(
                aspectRatio: coverAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Builder(
                    builder: (context) {
                      if (info == null) {
                        return const BookCoverPlaceholder();
                      }

                      if (coverUrl != null && coverUrl.isNotEmpty) {
                        return Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, event) {
                            if (event == null) return child;
                            return const BookCoverPlaceholder();
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: colors.tapEffect,
                            child: const Center(child: BookCoverPlaceholder(isNotFound: true)),
                          ),
                        );
                      }

                      return Container(
                        color: colors.tapEffect,
                        child: const Center(child: BookCoverPlaceholder(isNotFound: true)),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body1Bold,
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 6),
            if (showStars) ...[
              Row(
                children: [
                  Icon(Icons.star_rounded, color: colors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(info?.isbn13 != null ? '4.8' : '–', style: AppTextStyles.body2Regular),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (showPercentage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: colors.tapEffect,
                  color: colors.primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$percentage% read',
                style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
