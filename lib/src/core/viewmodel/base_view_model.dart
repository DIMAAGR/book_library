import 'package:book_library/src/core/state/ui_event.dart';
import 'package:flutter/foundation.dart';

abstract class BaseViewModel {
  final ValueNotifier<UiEvent?> event = ValueNotifier<UiEvent?>(null);
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @protected
  void emit(UiEvent e) {
    if (_disposed) return;
    event.value = e;
  }

  void consumeEvent() {
    if (_disposed) return;
    event.value = null;
  }

  @mustCallSuper
  void dispose() {
    _disposed = true;
    event.dispose();
  }
}
