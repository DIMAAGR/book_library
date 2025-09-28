import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_colors.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/core/theme/app_theme_mode_enum.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData resolve(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return light();
      case AppThemeMode.dark:
        return dark();
      case AppThemeMode.sepia:
        return sepia();
    }
  }

  static ThemeData light() {
    final colors = const AppColorsLight();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      extensions: [AppColorsExtension(colors)],
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: AppTextStyles.captionBold,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        textStyle: AppTextStyles.body1Regular,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData dark() {
    final colors = const AppColorsDark();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      extensions: [AppColorsExtension(colors)],
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: AppTextStyles.captionBold,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF202020),
        textStyle: AppTextStyles.body1Regular.copyWith(color: colors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData sepia() {
    final colors = const AppColorsSepia();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      extensions: [AppColorsExtension(colors)],
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: AppTextStyles.captionBold,
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        textStyle: AppTextStyles.body1Regular.copyWith(color: colors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
