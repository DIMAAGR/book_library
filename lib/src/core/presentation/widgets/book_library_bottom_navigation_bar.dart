import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookLibraryBottomNavigationBar extends StatelessWidget {
  const BookLibraryBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        switch (i) {
          case 0:
            break;
          case 1:
            context.goNamed(AppRoutes.explore);
            break;
          case 2:
            context.goNamed(AppRoutes.saved);
            break;
          case 3:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
