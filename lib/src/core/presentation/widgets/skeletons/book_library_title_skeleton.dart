import 'package:book_library/src/core/presentation/widgets/shimmers.dart';
import 'package:flutter/material.dart';

class BookLibraryTitleSkeleton extends StatelessWidget {
  const BookLibraryTitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerBox(width: 160, height: 22, borderRadius: BorderRadius.all(Radius.circular(6))),
    );
  }
}
