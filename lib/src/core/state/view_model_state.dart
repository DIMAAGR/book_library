class ViewModelState<E, S> {
  ViewModelState(this._success, this._error);
  final S? _success;
  final E? _error;

  bool get isInitial => this is InitialState<E, S>;
  bool get isLoading => this is LoadingState<E, S>;
  bool get isSuccess => this is SuccessState<E, S>;
  bool get isError => this is ErrorState<E, S>;

  S? get successOrNull => this is SuccessState<E, S> ? (this as SuccessState<E, S>).success : null;
  E? get errorOrNull => this is ErrorState<E, S> ? (this as ErrorState<E, S>).error : null;

  T? mapSuccess<T>(T Function(S) fn) => isSuccess ? fn((this as SuccessState<E, S>).success) : null;
  T? mapError<T>(T Function(E) fn) => isError ? fn((this as ErrorState<E, S>).error) : null;

  ViewModelState<E, T> map<T>(T Function(S) onSuccess) {
    if (this is SuccessState<E, S>) {
      final v = (this as SuccessState<E, S>).success;
      return SuccessState<E, T>(onSuccess(v));
    }
    if (this is LoadingState<E, S>) return LoadingState<E, T>();
    if (this is InitialState<E, S>) return InitialState<E, T>();
    final err = (this as ErrorState<E, S>).error;
    return ErrorState<E, T>(err);
  }

  T fold<T>({
    required T Function() onInitial,
    required T Function() onLoading,
    required T Function(S) onSuccess,
    required T Function(E) onError,
  }) {
    if (isInitial) return onInitial();
    if (isLoading) return onLoading();
    if (isSuccess) return onSuccess((this as SuccessState<E, S>).success);
    return onError((this as ErrorState<E, S>).error);
  }
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
