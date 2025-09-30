import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({super.key, required this.onPressed, required this.isFavorited});

  final VoidCallback onPressed;
  final bool isFavorited;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(54, 54),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Theme.of(context).colors.border),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),

        backgroundColor: Theme.of(context).colors.background,
        foregroundColor: isFavorited
            ? Theme.of(context).colors.primary
            : Theme.of(context).colors.textPrimary,
        elevation: 0,
      ),
      child: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, size: 24),
    );
  }
}
