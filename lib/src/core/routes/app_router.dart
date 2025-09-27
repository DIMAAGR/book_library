import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/features/home/presentation/view/home_view.dart';
import 'package:book_library/src/features/launcher/presentation/view/launcher_view.dart';
import 'package:book_library/src/features/onboard/presentation/view/onboard_view.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final getIt = GetIt.instance;

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        name: AppRoutes.launcher,
        path: '/',
        builder: (context, state) => LauncherView(viewModel: getIt()),
      ),
      GoRoute(
        name: AppRoutes.onboard,
        path: '/onboard',
        builder: (context, state) => OnboardView(viewModel: getIt()),
      ),
      GoRoute(name: AppRoutes.home, path: '/home', builder: (context, state) => const HomeView()),
    ],
  );
}
