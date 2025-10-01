import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_colors.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';
import 'package:flutter/material.dart';

class LineHeightPanel extends StatelessWidget {
  const LineHeightPanel({super.key, required this.onLineHeightChanged, required this.lineHeight});

  final void Function(ReaderLineHeight) onLineHeightChanged;
  final ReaderLineHeight lineHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        Text('Line Height', style: AppTextStyles.body1Bold.copyWith(color: colors.textSecondary)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChoicePill(
                colors: colors,
                icon: Icons.dehaze_rounded,
                label: 'Compact',
                selected: lineHeight == ReaderLineHeight.compact,
                onTap: () => onLineHeightChanged(ReaderLineHeight.compact),
              ),
              _ChoicePill(
                colors: colors,
                icon: Icons.dehaze_rounded,
                label: 'Comfortable',
                selected: lineHeight == ReaderLineHeight.comfortable,
                onTap: () => onLineHeightChanged(ReaderLineHeight.comfortable),
              ),
              _ChoicePill(
                colors: colors,
                icon: Icons.dehaze_rounded,
                label: 'Spacious',
                selected: lineHeight == ReaderLineHeight.spacious,
                onTap: () => onLineHeightChanged(ReaderLineHeight.spacious),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 88,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? colors.textSecondary : colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? colors.textLight : colors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.body2Regular.copyWith(
                  color: selected ? colors.textLight : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
