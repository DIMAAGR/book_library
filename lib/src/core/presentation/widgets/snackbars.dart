import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

abstract class BookLibrarySnackBars {
  static void successSnackbar(BuildContext context, String message) {
    final c = Theme.of(context).colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: c.success,
        content: Row(
          children: [
            Icon(Icons.done, color: c.textLight),
            const SizedBox(width: 8),
            Text(message, style: AppTextStyles.body2Regular.copyWith(color: c.textLight)),
          ],
        ),
      ),
    );
  }

  static void errorSnackBar(BuildContext context, String message) {
    final c = Theme.of(context).colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: c.error,
        content: Row(
          children: [
            Icon(Icons.error_outline, color: c.textLight),
            const SizedBox(width: 8),
            Text(message, style: AppTextStyles.body2Regular.copyWith(color: c.textLight)),
          ],
        ),
      ),
    );
  }

  static void informativeSnackBar(BuildContext context, String message) {
    final c = Theme.of(context).colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: c.primary,
        content: Row(
          children: [
            Icon(Icons.info_outline, color: c.textLight),
            const SizedBox(width: 8),
            Text(message, style: AppTextStyles.body2Regular.copyWith(color: c.textLight)),
          ],
        ),
      ),
    );
  }
}
