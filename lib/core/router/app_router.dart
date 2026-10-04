import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/choose_username_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/location_permission_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dev/presentation/ds_preview_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/run_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/run/presentation/countdown_screen.dart';
import '../../features/run/presentation/pre_run_screen.dart';
import '../../features/run/presentation/run_screen.dart';
import '../../features/run/presentation/run_summary_screen.dart';
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

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;

      final publicRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
        AppRoutes.username,
        AppRoutes.permission,
        AppRoutes.dsPreview,
      };

      // If not authenticated and trying to access a protected route → login
      if (!isAuth && !publicRoutes.contains(loc)) {
        return AppRoutes.login;
      }

      // Root → splash
      if (loc == AppRoutes.root) return AppRoutes.splash;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, _) => AppRoutes.splash,
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.username,
        builder: (_, _) => const ChooseUsernameScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.permission,
        builder: (_, _) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.preRun,
        builder: (_, _) => const PreRunScreen(),
      ),
      GoRoute(
        path: AppRoutes.countdown,
        builder: (_, _) => const CountdownScreen(),
      ),
      GoRoute(
        path: AppRoutes.activeRun,
        builder: (_, _) => const ActiveRunScreen(),
      ),
      GoRoute(
        path: AppRoutes.runSummary,
        builder: (context, state) => RunSummaryScreen(
          extra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, _) => const HistoryScreen(),
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
        builder: (context, state) => ShareScreen(
          extra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dsPreview,
        builder: (_, _) => const DsPreviewScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
