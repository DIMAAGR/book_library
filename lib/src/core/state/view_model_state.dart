class ViewModelState<E, S> {
  ViewModelState(this._success, this._error);
  final S? _success;
  final E? _error;
}

class InitialState<E, S> extends ViewModelState<E, S> {
  InitialState() : super(null, null);
}

class LoadingState<E, S> extends ViewModelState<E, S> {
  LoadingState() : super(null, null);
}

class SuccessState<E, S> extends ViewModelState<E, S> {
  SuccessState(S success) : super(success, null);

  S get success => _success!;
}

class ErrorState<E, S> extends ViewModelState<E, S> {
  ErrorState(E error) : super(null, error);

  E get error => _error!;
}
