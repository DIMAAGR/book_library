import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class FontSizePanel extends StatelessWidget {
  const FontSizePanel({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onFontSizeChanged,
  });

  final double value;
  final double min;
  final double max;
  final void Function(double) onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text('A-', style: AppTextStyles.subtitle1Medium.copyWith(color: color.textPrimary)),
          Expanded(
            child: Slider(value: value, min: min, max: max, onChanged: onFontSizeChanged),
          ),
          Text('A+', style: AppTextStyles.subtitle1Medium.copyWith(color: color.textPrimary)),
        ],
      ),
    );
  }
}
