import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/features/search/domain/strategies/sort_strategy.dart';
import 'package:book_library/src/features/search/domain/value_objects/book_query.dart';
import 'package:book_library/src/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onTextChanged,
    required this.onClear,
    required this.onApply,
    required this.range,
    required this.sort,
  });
  final Function(String) onTextChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;
  final ValueNotifier<PublishedRange> range;
  final ValueNotifier<SortStrategy> sort;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search books by title',
                  border: InputBorder.none,
                ),
                onChanged: onTextChanged,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: c.textSecondary),
              onPressed: () {
                controller.clear();
                onTextChanged('');
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.filter_list_rounded, color: c.primary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  builder: (_) => SearchFilterSheet(
                    range: range,
                    sort: sort,
                    onApply: onApply,
                    onClear: onClear,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);
}
