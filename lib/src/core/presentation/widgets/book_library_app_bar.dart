import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookLibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BookLibraryAppBar({
    super.key,
    this.showMenu = false,
    this.showSettings = false,
    this.showSearch = false,
    this.showShare = false,
    this.onSharePressed,
    required this.title,
    this.onMenuTap,
    this.onSettingsPressed,
  });
  final bool showMenu;
  final bool showSettings;
  final bool showSearch;
  final bool showShare;
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSharePressed;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showMenu
          ? IconButton(
              icon: Icon(Icons.menu_rounded, color: colors.textPrimary),
              onPressed: onMenuTap,
            )
          : null,
      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(Icons.search_rounded, color: colors.textPrimary),
            onPressed: () {
              context.pushNamed(AppRoutes.search);
            },
          ),
        if (showSettings)
          IconButton(
            icon: Icon(Icons.settings_rounded, color: colors.textPrimary),
            onPressed: onSettingsPressed,
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
