import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class InfoContent extends StatelessWidget {
  const InfoContent({super.key, this.leading, required this.value, required this.label});
  final Widget? leading;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.background,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(value, style: AppTextStyles.subtitle2Medium),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}
