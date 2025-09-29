import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/books/presentation/widgets/book_card.dart';
import 'package:book_library/src/features/home/presentation/view_model/home_state_object.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HorizontalBooksList extends StatelessWidget {
  const HorizontalBooksList({
    super.key,
    required this.list,
    required this.resolveFor,
    required this.homeState,
    this.showPercentage = true,
    this.showStars = true,
  });

  final List<BookEntity> list;
  final Future<void> Function(BookEntity book) resolveFor;
  final ValueListenable<HomeStateObject> homeState;
  final bool showPercentage;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 424,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final book = list[i];
          resolveFor(book);

          return ValueListenableBuilder<HomeStateObject>(
            valueListenable: homeState,
            builder: (_, hs, __) {
              final info = hs.byBookId[book.id];
              return BookCard(
                book: book,
                info: info,
                onTap: () {},
                showPercentage: showPercentage,
                showStars: showStars,
              );
            },
          );
        },
      ),
    );
  }
}
