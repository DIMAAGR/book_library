import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:book_library/src/features/books/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.items,
    required this.activeId,
    required this.onTap,
  });

  final List<CategoryEntity> items;
  final String? activeId;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: items.map((c) {
          final active = c.id == activeId;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onTap(c.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? colors.selectionEffect : colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  c.name,
                  style: AppTextStyles.body2Regular.copyWith(
                    color: active ? colors.primaryDark : colors.textPrimary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
