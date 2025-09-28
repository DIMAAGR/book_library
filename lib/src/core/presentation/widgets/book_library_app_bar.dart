import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';

class BookLibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BookLibraryAppBar({
    super.key,
    this.showMenu = false,
    this.showSettings = false,
    this.showSearch = false,
    required this.title,
    this.onMenuTap,
    this.onSearchTap,
    this.onSettingsPressed,
  });
  final bool showMenu;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final bool showSettings;
  final bool showSearch;
  final String title;
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
            onPressed: onSearchTap,
          ),
        if (showSettings)
          IconButton(
            icon: Icon(Icons.settings_rounded, color: colors.textPrimary),
            onPressed: onSettingsPressed,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
