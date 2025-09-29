import 'package:book_library/src/core/routes/app_routes.dart';
import 'package:book_library/src/features/explorer/presentation/view/explorer_view.dart';
import 'package:book_library/src/features/favorites/presentation/view/favorites_view.dart';
import 'package:book_library/src/features/home/presentation/view/home_view.dart';
import 'package:book_library/src/features/launcher/presentation/view/launcher_view.dart';
import 'package:book_library/src/features/library/presentation/view/library_view.dart';
import 'package:book_library/src/features/onboard/presentation/view/onboard_view.dart';
import 'package:book_library/src/features/search/presentation/view/search_view.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final getIt = GetIt.instance;

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        name: AppRoutes.launcher,
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage(child: LauncherView(viewModel: getIt())),
      ),
      GoRoute(
        name: AppRoutes.onboard,
        path: AppRoutes.onboard,
        builder: (context, state) => OnboardView(viewModel: getIt()),
      ),
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.home,
        pageBuilder: (context, state) => NoTransitionPage(child: HomeView(viewModel: getIt())),
      ),
      GoRoute(
        path: AppRoutes.library,
        name: AppRoutes.library,
        builder: (context, state) => LibraryView(viewModel: getIt()),
      ),
      GoRoute(
        name: AppRoutes.search,
        path: AppRoutes.search,
        builder: (context, state) => SearchView(viewModel: getIt()),
      ),
      GoRoute(
        path: AppRoutes.explore,
        name: AppRoutes.explore,
        pageBuilder: (context, state) => NoTransitionPage(child: ExploreView(viewModel: getIt())),
      ),
      GoRoute(
        path: AppRoutes.saved,
        name: AppRoutes.saved,
        pageBuilder: (context, state) => NoTransitionPage(child: FavoritesView(viewModel: getIt())),
      ),
    ],
  );
}
