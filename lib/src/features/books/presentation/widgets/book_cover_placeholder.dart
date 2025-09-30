import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BookCoverPlaceholder extends StatelessWidget {
  const BookCoverPlaceholder({super.key, this.isNotFound = false});
  final bool isNotFound;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    final highlight = colors.primaryDark;
    final base = colors.tapEffect;

    return isNotFound
        ? Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.book_outlined, size: 64, color: colors.border),
              Positioned(
                right: 2,
                top: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.textLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.error, width: 2),
                  ),
                  child: Icon(Icons.close, size: 14, color: colors.error),
                ),
              ),
            ],
          )
        : Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: Center(child: Icon(Icons.book_outlined, size: 64, color: base)),
          );
  }
}
