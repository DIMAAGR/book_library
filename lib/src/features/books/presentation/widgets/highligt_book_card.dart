import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_cover_placeholder.dart';
import 'package:book_library/src/features/books_details/domain/entites/external_book_info_entity.dart';
import 'package:flutter/material.dart';

class HighlightBookCard extends StatelessWidget {
  const HighlightBookCard({super.key, required this.book, this.info, required this.onReadNow});
  final VoidCallback onReadNow;
  final BookEntity book;
  final ExternalBookInfoEntity? info;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final coverUrl = info?.coverUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 128,
              child: AspectRatio(
                aspectRatio: 3 / 4,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.h6,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author.split(',').first,
                    style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onReadNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Read now',
                      style: AppTextStyles.subtitle1Medium.copyWith(color: colors.textLight),
                    ),
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
