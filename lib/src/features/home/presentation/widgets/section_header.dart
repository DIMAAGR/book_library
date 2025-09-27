import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onTap, this.subtitle})
    : assert((action == null && onTap == null) || (action != null && onTap != null));
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h5)),
              if (onTap != null && action != null)
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    action!,
                    style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
                  ),
                ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                subtitle!,
                style: AppTextStyles.body2Regular.copyWith(color: colors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
