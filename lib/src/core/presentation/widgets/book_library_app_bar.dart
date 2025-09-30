import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookLibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BookLibraryAppBar({
    super.key,
    this.showSearch = false,
    this.showShare = false,
    this.onSharePressed,
    required this.title,
  });
  final bool showSearch;
  final bool showShare;
  final String title;
  final VoidCallback? onSharePressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return AppBar(
      title: Text(title),
      centerTitle: true,

      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(Icons.search_rounded, color: colors.textPrimary),
            onPressed: () {
              context.pushNamed(AppRoutes.search);
            },
          ),

        if (showShare)
          IconButton(
            icon: Icon(Icons.share_rounded, color: colors.textPrimary),
            onPressed: onSharePressed,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
