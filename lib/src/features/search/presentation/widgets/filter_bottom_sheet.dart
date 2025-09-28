import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/presentation/widgets/book_library_button.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:book_library/src/features/search/presentation/widgets/filter_choice_chip.dart';
import 'package:flutter/material.dart';

class SearchFilterSheet extends StatelessWidget {
  const SearchFilterSheet({
    super.key,
    required this.range,
    required this.sort,
    required this.onApply,
    required this.onClear,
  });

  final ValueNotifier<PublishedRange> range;
  final ValueNotifier<SortStrategy> sort;
  final VoidCallback onApply;
  final VoidCallback onClear;

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
            ValueListenableBuilder<SortStrategy>(
              valueListenable: sort,
              builder: (_, current, __) => Wrap(
                children: [
                  FilterChoiceChip(
                    label: 'A–Z',
                    selected: _sameType(current, const SortByAZ()),
                    onTap: () => sort.value = const SortByAZ(),
                  ),
                  FilterChoiceChip(
                    label: 'Newest',
                    selected: _sameType(current, const SortByNewest()),
                    onTap: () => sort.value = const SortByNewest(),
                  ),
                  FilterChoiceChip(
                    label: 'Oldest',
                    selected: _sameType(current, const SortByOldest()),
                    onTap: () => sort.value = const SortByOldest(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text('Year published', style: AppTextStyles.body1Bold),
            const SizedBox(height: 8),
            ValueListenableBuilder<PublishedRange>(
              valueListenable: range,
              builder: (_, current, __) => Wrap(
                children: [
                  FilterChoiceChip(
                    label: 'Any',
                    selected: current == PublishedRange.any,
                    onTap: () => range.value = PublishedRange.any,
                  ),
                  FilterChoiceChip(
                    label: 'Recent (2020+)',
                    selected: current == PublishedRange.recent2020plus,
                    onTap: () => range.value = PublishedRange.recent2020plus,
                  ),
                  FilterChoiceChip(
                    label: 'Classic (< 2000)',
                    selected: current == PublishedRange.classicBefore2000,
                    onTap: () => range.value = PublishedRange.classicBefore2000,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            BookLibraryButton(
              text: 'Apply filters',
              textStyle: AppTextStyles.subtitle1Medium.copyWith(color: colors.textLight),
              onPressed: () {
                onApply();
                Navigator.of(context).maybePop();
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  onClear();
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
