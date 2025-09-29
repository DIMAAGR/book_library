import 'package:book_library/src/core/presentation/widgets/skeletons/book_library_horizontal_row_skeleton.dart';
import 'package:flutter/material.dart';

class FavoritesSkeleton extends StatelessWidget {
  const FavoritesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemBuilder: (_, __) => const BookLibraryHorizontalRowSkeleton(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 8,
    );
  }
}
