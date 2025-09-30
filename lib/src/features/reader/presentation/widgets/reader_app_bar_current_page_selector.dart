import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class PageSelector extends StatelessWidget {
  const PageSelector({super.key, this.onPrevPage, this.onNextPage, required this.current});

  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;
  final String current;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colors;
    return Row(
      children: [
        Text(current, style: AppTextStyles.body1Regular.copyWith(color: color.textSecondary)),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: color.textSecondary),
          onPressed: onPrevPage,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: color.textSecondary),
          onPressed: onNextPage,
        ),
      ],
    );
  }
}
