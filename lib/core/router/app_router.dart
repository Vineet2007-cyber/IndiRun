import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/run_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/run/presentation/run_screen.dart';
import '../../features/share/presentation/share_screen.dart';
import 'app_routes.dart';

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final location = state.matchedLocation;

      final isAuthRoute = location == AppRoutes.auth || location == AppRoutes.onboarding;

      // If unauthenticated, redirect from protected routes to auth
      if (!isAuth && !isAuthRoute) {
        return AppRoutes.auth;
      }

      // If already authenticated and trying to access auth/onboarding, redirect to home
      if (isAuth && isAuthRoute) {
        return AppRoutes.home;
      }

      // Handle root route
      if (location == AppRoutes.root) {
        return isAuth ? AppRoutes.home : AppRoutes.auth;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) {
          final isAuth = ref.read(authControllerProvider).isAuthenticated;
          return isAuth ? AppRoutes.home : AppRoutes.auth;
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.run,
        builder: (context, state) => const RunScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
        routes: [
          GoRoute(
            path: ':runId',
            builder: (context, state) {
              final runId = state.pathParameters['runId'] ?? '';
              return RunDetailScreen(runId: runId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.share,
        builder: (context, state) => const ShareScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
