import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/indirun_logo.dart';
import '../../run/application/run_controller.dart';
import '../application/auth_controller.dart';

/// S01 Splash Screen
///
/// Implements:
/// - IndiRun branding & approved logo
/// - Progress indicator
/// - Initialization:
///   1. Initializes local database / preferences
///   2. Restores authentication session
///   3. Checks for unfinished run
///   4. Routes appropriately (Active Run, Home, or Login)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize local storage/database
      final prefs = await SharedPreferences.getInstance();

      // 2. Restore session is handled by AuthController (watching AuthRepository)
      // Allow slight delay for smooth visual presentation
      await Future.delayed(const Duration(milliseconds: 600));

      // 3. Check for unfinished run
      final hasUnfinishedStoredRun = prefs.getBool('indirun_has_active_run') ?? false;
      final activeRun = ref.read(activeRunProvider);
      final bool hasUnfinishedRun = hasUnfinishedStoredRun || activeRun.isActive;

      if (!mounted) return;

      // Wait until progress bar completes
      if (_progressController.isAnimating) {
        await _progressController.forward();
      }

      _routeToNext(hasUnfinishedRun);
    } catch (_) {
      if (mounted) {
        _routeToNext(false);
      }
    }
  }

  void _routeToNext(bool hasUnfinishedRun) {
    if (!mounted) return;
    final isAuth = ref.read(authControllerProvider).isAuthenticated;

    if (hasUnfinishedRun && isAuth) {
      context.go(AppRoutes.activeRun);
    } else if (isAuth) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Approved Logo circle
            const IndiRunLogo(size: 96),
            const SizedBox(height: AppDimensions.space20),
            // Brand Name
            Text(
              'INDIRUN',
              style: AppTextStyles.headlineLarge(color: AppColors.textLight).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            // Slogan
            Text(
              'Every run, your own.',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: AppDimensions.space24),
            // Loading progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 88),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    child: LinearProgressIndicator(
                      value: _progressController.value,
                      minHeight: 4,
                      backgroundColor: AppColors.outlineLight.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                },
              ),
            ),
            const Spacer(flex: 4),
            // Version footer
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space24),
              child: Text(
                'v1.0.0',
                style: AppTextStyles.caption(color: AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
