import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_colors.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';
import 'package:book_library/src/features/reader/presentation/widgets/reader_app_bar_bottom_button.dart';
import 'package:book_library/src/features/reader/presentation/widgets/reader_app_bar_current_page_selector.dart';
import 'package:book_library/src/features/reader/presentation/widgets/reader_app_bar_font_size_panel.dart';
import 'package:book_library/src/features/reader/presentation/widgets/reader_app_bar_line_height_panel.dart';
import 'package:book_library/src/features/reader/presentation/widgets/reader_app_bar_theme_mode_panel.dart';
import 'package:flutter/material.dart';

class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({
    super.key,
    required this.openPanel,
    required this.currentPageText,
    required this.fontSize,
    required this.minFontSize,
    required this.maxFontSize,
    required this.lineHeight,
    required this.themeSelectedIndex,
    this.onOpenPanelChanged,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.onThemeChanged,
    this.onPrevPage,
    this.onNextPage,
  });

  final ReaderPanel openPanel;
  final String currentPageText;

  final double fontSize;
  final double minFontSize;
  final double maxFontSize;

  final ReaderLineHeight lineHeight;
  final int themeSelectedIndex;

  final ValueChanged<ReaderPanel>? onOpenPanelChanged;
  final void Function(double) onFontSizeChanged;
  final void Function(ReaderLineHeight) onLineHeightChanged;
  final void Function(int) onThemeChanged;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;

  void _toggle(ReaderPanel p) {
    if (onOpenPanelChanged == null) return;
    onOpenPanelChanged!(openPanel == p ? ReaderPanel.none : p);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colors;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedCrossFade(
            crossFadeState: openPanel == ReaderPanel.none
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstChild: _PanelContainer(child: _buildPanelBody(color)),
            secondChild: const SizedBox.shrink(),
          ),

          Container(
            decoration: BoxDecoration(
              color: color.background,
              border: Border(top: BorderSide(color: color.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ReaderAppBarBottomButton(
                  icon: Icons.text_fields_rounded,
                  active: openPanel == ReaderPanel.fontSize,
                  onTap: () => _toggle(ReaderPanel.fontSize),
                ),
                const SizedBox(width: 16),
                ReaderAppBarBottomButton(
                  icon: Icons.format_line_spacing_rounded,
                  active: openPanel == ReaderPanel.lineHeight,
                  onTap: () => _toggle(ReaderPanel.lineHeight),
                ),
                const SizedBox(width: 16),
                ReaderAppBarBottomButton(
                  icon: Icons.color_lens_rounded,
                  active: openPanel == ReaderPanel.themeMode,
                  onTap: () => _toggle(ReaderPanel.themeMode),
                ),
                const Spacer(),
                PageSelector(
                  current: currentPageText,
                  onNextPage: onNextPage,
                  onPrevPage: onPrevPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelBody(AppColors c) {
    switch (openPanel) {
      case ReaderPanel.fontSize:
        return FontSizePanel(
          value: fontSize,
          min: minFontSize,
          max: maxFontSize,
          onFontSizeChanged: onFontSizeChanged,
        );

      case ReaderPanel.lineHeight:
        return LineHeightPanel(lineHeight: lineHeight, onLineHeightChanged: onLineHeightChanged);

      case ReaderPanel.themeMode:
        return ThemeModePanel(selectedTheme: themeSelectedIndex, onThemeChanged: onThemeChanged);

      case ReaderPanel.none:
        return const SizedBox.shrink();
    }
  }
}

class _PanelContainer extends StatelessWidget {
  const _PanelContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: child,
    );
  }
}
