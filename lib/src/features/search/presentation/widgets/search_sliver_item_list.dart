import 'dart:async';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/presentation/widgets/horizontal_book_card.dart';
import 'package:book_library/src/features/books_details/domain/entities/external_book_info_entity.dart';
import 'package:flutter/material.dart';

class SearchItemSliverList extends StatelessWidget {
  const SearchItemSliverList({
    super.key,
    required this.hasInfoFor,
    required this.resolveFor,
    required this.byBookId,
    required this.favorites,
    required this.toggleFavorite,
    required this.items,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 20),
    this.itemSpacing = 12,
  });

  final bool Function(String bookId) hasInfoFor;
  final void Function(BookEntity book) resolveFor;
  final ValueNotifier<Map<String, ExternalBookInfoEntity>> byBookId;
  final ValueNotifier<Set<String>> favorites;
  final Future<void> Function(String id) toggleFavorite;
  final List<BookEntity> items;

  final EdgeInsets padding;
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: padding,
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: itemSpacing),
        itemBuilder: (context, i) {
          final b = items[i];

          if (!hasInfoFor(b.id)) {
            scheduleMicrotask(() => resolveFor(b));
          }

          return ValueListenableBuilder<Map<String, ExternalBookInfoEntity>>(
            valueListenable: byBookId,
            builder: (_, infos, __) {
              final info = infos[b.id];
              return ValueListenableBuilder<Set<String>>(
                valueListenable: favorites,
                builder: (_, favs, __) => HorizontalBookCard(
                  book: b,
                  info: info,
                  isFavorite: favs.contains(b.id),
                  onFavoriteToggle: () => toggleFavorite(b.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
