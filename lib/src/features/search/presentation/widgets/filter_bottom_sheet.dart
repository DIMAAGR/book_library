import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_button.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:book_library/src/features/search/presentation/widgets/filter_choice_chip.dart';
import 'package:flutter/material.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({
    super.key,
    required this.initialRange,
    required this.initialSort,
    required this.onApply,
    required this.onClear,
  });

  final PublishedRange initialRange;
  final SortStrategy initialSort;
  final void Function(PublishedRange, SortStrategy) onApply;
  final VoidCallback onClear;

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late PublishedRange _range = widget.initialRange;
  late SortStrategy _sort = widget.initialSort;

  bool _sameType(SortStrategy a, SortStrategy b) => a.runtimeType == b.runtimeType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: AppTextStyles.h6),
            const SizedBox(height: 12),

            Text('Sort by', style: AppTextStyles.body1Bold),
            const SizedBox(height: 8),
            Wrap(
              children: [
                FilterChoiceChip(
                  label: 'A–Z',
                  selected: _sameType(_sort, const SortByAZ()),
                  onTap: () => setState(() => _sort = const SortByAZ()),
                ),
                FilterChoiceChip(
                  label: 'Newest',
                  selected: _sameType(_sort, const SortByNewest()),
                  onTap: () => setState(() => _sort = const SortByNewest()),
                ),
                FilterChoiceChip(
                  label: 'Oldest',
                  selected: _sameType(_sort, const SortByOldest()),
                  onTap: () => setState(() => _sort = const SortByOldest()),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text('Year published', style: AppTextStyles.body1Bold),
            const SizedBox(height: 8),
            Wrap(
              children: [
                FilterChoiceChip(
                  label: 'Any',
                  selected: _range == PublishedRange.any,
                  onTap: () => setState(() => _range = PublishedRange.any),
                ),
                FilterChoiceChip(
                  label: 'Recent (2020+)',
                  selected: _range == PublishedRange.recent2020plus,
                  onTap: () => setState(() => _range = PublishedRange.recent2020plus),
                ),
                FilterChoiceChip(
                  label: 'Classic (< 2000)',
                  selected: _range == PublishedRange.classicBefore2000,
                  onTap: () => setState(() => _range = PublishedRange.classicBefore2000),
                ),
              ],
            ),

            const SizedBox(height: 16),
            BookLibraryButton(
              text: 'Apply filters',
              textStyle: AppTextStyles.subtitle1Medium.copyWith(color: colors.textLight),
              onPressed: () {
                widget.onApply(_range, _sort);
                Navigator.of(context).maybePop();
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.of(context).maybePop();
                },
                child: const Text('Clear all'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
