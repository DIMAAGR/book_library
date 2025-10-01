import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/core/theme/app_theme_controller.dart';
import 'package:book_library/src/core/theme/app_theme_mode_enum.dart';
import 'package:book_library/src/features/books/domain/entities/book_entity.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_state_object.dart';
import 'package:book_library/src/features/reader/presentation/view_model/reader_view_model.dart';
import 'package:book_library/src/features/reader/presentation/widgets/reader_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReaderView extends StatefulWidget {
  const ReaderView({
    super.key,
    required this.book,
    required this.viewModel,
    required this.themeController,
  });

  final BookEntity book;
  final ReaderViewModel viewModel;
  final AppThemeController themeController;

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.init(book: widget.book, assetPath: 'assets/epub/example.epub');
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      final ratio = max == 0 ? 0.0 : (_scroll.position.pixels / max).clamp(0.0, 1.0);
      widget.viewModel.onScrollRatioChanged(ratio);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  double _lh(ReaderLineHeight h) => switch (h) {
    ReaderLineHeight.compact => 1.25,
    ReaderLineHeight.comfortable => 1.5,
    ReaderLineHeight.spacious => 1.75,
  };

  int _themeToIndex(AppThemeMode m) => switch (m) {
    AppThemeMode.light => 0,
    AppThemeMode.sepia => 1,
    AppThemeMode.dark => 2,
  };

  AppThemeMode _indexToTheme(int i) => switch (i) {
    0 => AppThemeMode.light,
    1 => AppThemeMode.sepia,
    _ => AppThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          ValueListenableBuilder(
            valueListenable: widget.viewModel.state,
            builder: (_, fav, __) {
              return IconButton(
                icon: fav.isFavorite
                    ? const Icon(Icons.bookmark)
                    : const Icon(Icons.bookmark_border),
                onPressed: () => widget.viewModel.toggleFavorite(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<ReaderStateObject>(
          valueListenable: widget.viewModel.state,
          builder: (_, st, __) {
            return st.state.fold(
              onInitial: () => const SizedBox.shrink(),
              onLoading: () => const Center(child: CircularProgressIndicator()),
              onError: (f) => Center(child: Text(f.message)),
              onSuccess: (payload) {
                final s = st.settings;
                final lh = _lh(s.lineHeight);

                return Stack(
                  children: [
                    CustomScrollView(
                      controller: _scroll,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          sliver: SliverList.separated(
                            itemCount: payload.paragraphs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final p = payload.paragraphs[i];
                              final isStart =
                                  i == 0 ||
                                  (p.title.isNotEmpty &&
                                      payload.paragraphs[i - 1].title != p.title);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isStart && p.title.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(p.title, style: AppTextStyles.subtitle1Medium),
                                    const SizedBox(height: 8),
                                  ],
                                  Text(
                                    p.text,
                                    style: AppTextStyles.body1Regular.copyWith(
                                      height: lh,
                                      fontSize: s.fontSize,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ReaderBottomBar(
                        openPanel: st.openPanel,
                        onOpenPanelChanged: widget.viewModel.setOpenPanel,

                        currentPageText: '${st.currentPage} / ${st.totalPages}',

                        fontSize: s.fontSize,
                        minFontSize: 14,
                        maxFontSize: 26,
                        onFontSizeChanged: widget.viewModel.setFont,

                        lineHeight: s.lineHeight,
                        onLineHeightChanged: widget.viewModel.setLine,

                        themeSelectedIndex: _themeToIndex(widget.themeController.mode.value),
                        onThemeChanged: (i) => widget.themeController.set(_indexToTheme(i)),

                        onPrevPage: () {
                          final pos = _scroll.position.pixels;
                          _scroll.animateTo(
                            (pos - 600).clamp(0, _scroll.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                          );
                        },
                        onNextPage: () {
                          final pos = _scroll.position.pixels;
                          _scroll.animateTo(
                            (pos + 600).clamp(0, _scroll.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
