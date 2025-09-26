import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/features/onboard/view/onboard_view.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(name: AppRoutes.onboard, path: '/', builder: (context, state) => OnboardView()),
    ],
  );
}
