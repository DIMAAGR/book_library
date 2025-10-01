import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookLibraryBottomNavigationBar extends StatelessWidget {
  const BookLibraryBottomNavigationBar({super.key});

  int _currentIndex(BuildContext context) {
    final route = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    return route.contains(AppRoutes.home)
        ? 0
        : route.contains(AppRoutes.explore)
        ? 1
        : route.contains(AppRoutes.saved)
        ? 2
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex(context),
      onTap: (i) {
        switch (i) {
          case 0:
            if (_currentIndex(context) != 0) context.goNamed(AppRoutes.home);
            break;
          case 1:
            if (_currentIndex(context) != 1) context.goNamed(AppRoutes.explore);
            break;
          case 2:
            if (_currentIndex(context) != 2) context.goNamed(AppRoutes.saved);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
      ],
    );
  }
}
