import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_cover_placeholder.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HorizontalBookCard extends StatelessWidget {
  const HorizontalBookCard({
    super.key,
    required this.book,
    this.info,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.rank,
    this.showRank = false,
  });

  final BookEntity book;
  final ExternalBookInfoEntity? info;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  final int? rank;
  final bool showRank;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final coverUrl = info?.coverUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushNamed(AppRoutes.bookDetails, extra: book);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showRank && rank != null) ...[
              Text('#$rank', style: AppTextStyles.h6.copyWith(color: colors.textSecondary)),
              const SizedBox(width: 12),
            ],

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 86,
                child: coverUrl != null && coverUrl.isNotEmpty
                    ? Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const BookCoverPlaceholder(isNotFound: true),
                        loadingBuilder: (ctx, child, evt) =>
                            evt == null ? child : const BookCoverPlaceholder(),
                      )
                    : const BookCoverPlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle1Medium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        info?.isbn13 != null ? '4.8 (12.5k)' : '–',
                        style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? colors.primary : colors.textSecondary,
              ),
              splashRadius: 22,
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
          ],
        ),
      ),
    );
  }
}
