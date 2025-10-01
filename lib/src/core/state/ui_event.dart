abstract class UiEvent {}

class NavigateTo extends UiEvent {
  NavigateTo(this.route);
  final String route;
}

class Pop extends UiEvent {}

class ShowSnackBar extends UiEvent {
  ShowSnackBar(this.message);
  final String message;
}

class ShowErrorSnackBar extends UiEvent {
  ShowErrorSnackBar(this.message);
  final String message;
}

class ShowSuccessSnackBar extends UiEvent {
  ShowSuccessSnackBar(this.message);
  final String message;
}
