import 'dart:ui';

sealed class AppColors {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.background,
    required this.surface,
    required this.border,
    required this.error,
    required this.warning,
    required this.success,
    required this.tapEffect,
    required this.selectionEffect,
    required this.primaryBlack,
  });
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryBlack;

  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;

  final Color background;
  final Color surface;
  final Color border;

  final Color error;
  final Color warning;
  final Color success;

  final Color tapEffect;
  final Color selectionEffect;
}

class AppColorsLight extends AppColors {
  const AppColorsLight()
    : super(
        primary: const Color(0xFF7C3AED),
        primaryLight: const Color(0xFF9F67F8),
        primaryDark: const Color(0xFF5B21B6),
        primaryBlack: const Color(0xFF2E1065),
        textPrimary: const Color(0xFF111827),
        textSecondary: const Color(0xFF6B7280),
        textLight: const Color(0xFFFFFFFF),
        background: const Color(0xFFFFFFFF),
        surface: const Color(0xFFF8F9FA),
        border: const Color(0xFFE5E7EB),
        error: const Color(0xFFEF4444),
        warning: const Color(0xFFF59E0B),
        success: const Color(0xFF10B981),
        tapEffect: const Color(0xFFF3F4F6),
        selectionEffect: const Color(0xFFEDE9FE),
      );
}

class AppColorsDark extends AppColors {
  const AppColorsDark()
    : super(
        primary: const Color(0xFF9F67F8),
        primaryLight: const Color(0xFFB794F4),
        primaryDark: const Color(0xFF7C3AED),
        primaryBlack: const Color(0xFFDCCEB0),
        textPrimary: const Color(0xFFF9FAFB),
        textSecondary: const Color(0xFFD1D5DB),
        textLight: const Color(0xFF111827),
        background: const Color(0xFF111827),
        surface: const Color(0xFF1F2937),
        border: const Color(0xFF374151),
        error: const Color(0xFFF87171),
        warning: const Color(0xFFFBBF24),
        success: const Color(0xFF34D399),
        tapEffect: const Color(0xFF1F2937),
        selectionEffect: const Color(0xFF2E1065),
      );
}

class AppColorsSepia extends AppColors {
  const AppColorsSepia()
    : super(
        primary: const Color(0xFF7C3AED),
        primaryLight: const Color(0xFF9F67F8),
        primaryDark: const Color(0xFF5B21B6),
        primaryBlack: const Color(0xFF3B2F2F),
        textPrimary: const Color(0xFF5B4636),
        textSecondary: const Color(0xFF7C6F62),
        textLight: const Color(0xFFFFFFFF),
        background: const Color(0xFFF4ECD8),
        surface: const Color(0xFFECE2C8),
        border: const Color(0xFFD8CBB2),
        error: const Color(0xFFEF4444),
        warning: const Color(0xFFF59E0B),
        success: const Color(0xFF10B981),
        tapEffect: const Color(0xFFE6DBC2),
        selectionEffect: const Color(0xFFDCCEB0),
      );
}
