import 'package:book_library/src/core/presentation/commands/undo_command.dart';
import 'package:book_library/src/core/presentation/extensions/color_ext.dart';
import 'package:flutter/material.dart';

class PendingCommandController {
  UndoCommand? _pending;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snack;

  Future<void> start({
    required BuildContext context,
    required UndoCommand command,
    required String message,

    String? undoLabel,
    Duration duration = const Duration(seconds: 4),
  }) async {
    undoLabel ??= 'Desfazer';
    await _commitIfAny();

    _pending = command;

    if (context.mounted) {
      _snack = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colors.textSecondary,
          content: Text(message, style: TextStyle(color: Theme.of(context).colors.textLight)),
          duration: duration,
          action: SnackBarAction(
            textColor: Theme.of(context).colors.textLight,
            label: undoLabel.toUpperCase(),
            onPressed: () => _pending?.undo(),
          ),
        ),
      );
    }

    _snack!.closed.then((_) async {
      if (_pending != null && !_pending!.undone && !_pending!.committed) {
        try {
          await _pending!.commit();
        } catch (_) {}
      }
      _reset();
    });
  }

  Future<void> _commitIfAny() async {
    if (_pending != null && !_pending!.undone && !_pending!.committed) {
      _snack?.close();
      try {
        await _pending!.commit();
      } finally {
        _reset();
      }
    } else {
      _reset();
    }
  }

  void cancel() {
    _snack?.close();
    _reset();
  }

  void _reset() {
    _pending = null;
    _snack = null;
  }
}
