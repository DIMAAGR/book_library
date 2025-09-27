import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:book_library/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BookLibraryButton extends StatelessWidget {
  const BookLibraryButton({super.key, required this.text, required this.onPressed, this.textStyle});
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Theme.of(context).colors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style:
            textStyle ?? AppTextStyles.button.copyWith(color: Theme.of(context).colors.textLight),
      ),
    );
  }
}
