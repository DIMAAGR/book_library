import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ThemeModePanel extends StatelessWidget {
  const ThemeModePanel({super.key, required this.selectedTheme, required this.onThemeChanged});

  final int selectedTheme;
  final void Function(int) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SegmentChip(
            label: 'Light',
            selected: selectedTheme == 0,
            onTap: () => onThemeChanged(0),
          ),
          _SegmentChip(
            label: 'Sepia',
            selected: selectedTheme == 1,
            onTap: () => onThemeChanged(1),
          ),
          _SegmentChip(
            label: 'Dark',
            selected: selectedTheme == 2,
            onTap: () => onThemeChanged(2), //
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.textSecondary : colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: AppTextStyles.body1Regular.copyWith(
              color: selected ? colors.textLight : colors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
