import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_button.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.onRetry, required this.onOpenSettings});

  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.tapEffect),
            child: Icon(Icons.cloud_off_outlined, size: 56, color: colors.border),
          ),
          const SizedBox(height: 32),

          Text(
            "You're offline",
            style: AppTextStyles.h5.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Connect to the internet to access your library and continue reading your books.',
            style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          BookLibraryButton(
            text: 'Retry',
            onPressed: onRetry,
            textStyle: AppTextStyles.subtitle1Medium.copyWith(color: colors.textLight),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: onOpenSettings,
            child: Text(
              'Open Settings',
              style: AppTextStyles.body1Regular.copyWith(color: colors.primary),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Check your WiFi connection or mobile data settings to get back online.',
            style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
