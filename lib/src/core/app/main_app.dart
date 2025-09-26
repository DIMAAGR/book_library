import 'package:book_library/src/core/routes/app_router.dart';
import 'package:book_library/src/core/theme/app_theme_controller.dart';
import 'package:book_library/src/core/theme/app_theme_mode_enum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = GetIt.I<AppThemeController>();

    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: theme.mode,
      builder: (_, mode, __) {
        return MaterialApp.router(
          routerConfig: buildRouter(),
          title: 'Booklist',
          debugShowCheckedModeBanner: false,
          theme: theme.theme,
        );
      },
    );
  }
}
