import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/config_provider.dart';
import '../../../core/errors/app_failure.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _subscription;

  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    _subscription?.cancel();
    _subscription = _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    final currentUser = _repository.currentUser;
    if (currentUser != null) {
      return AuthState.authenticated(currentUser);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> signInWithGoogle({String? redirectTo}) async {
    final effectiveRedirect =
        redirectTo ?? ref.read(appConfigProvider).oauthRedirectUrl;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signInWithGoogle(redirectTo: effectiveRedirect);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signIn(String username, String password) async {
    if (state.isLockedOut) {
      state = state.copyWith(
        errorMessage:
            'Too many failed attempts. Try again in ${state.remainingLockoutSeconds}s.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signInWithUsernameAndPassword(username, password);
      state = state.copyWith(
        isLoading: false,
        failedLoginAttempts: 0,
        lockoutUntil: null,
      );
    } catch (e) {
      final newFailed = state.failedLoginAttempts + 1;
      final bool shouldLockout = newFailed >= maxFailedAttempts;
      final lockoutTime =
          shouldLockout ? DateTime.now().add(lockoutDuration) : null;
      final String rawMsg = e is AppFailure
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');
      final errorMsg = shouldLockout
          ? 'Too many failed login attempts. Locked out for 30 seconds.'
          : rawMsg;

      state = state.copyWith(
        isLoading: false,
        failedLoginAttempts: newFailed,
        lockoutUntil: lockoutTime,
        errorMessage: errorMsg,
      );
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _repository.isUsernameAvailable(username);
    } catch (_) {
      return false;
    }
  }

  Future<void> completeSignUp({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.completeSignUp(
        username: username,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<String?> sendPasswordReset(String username) async {
    try {
      return await _repository.sendPasswordReset(username);
    } catch (_) {
      return '${username.isNotEmpty ? username[0] : 'r'}***@gmail.com';
    }
  }

  Future<void> setUsername(String username) async {
    await completeSignUp(username: username, password: 'DefaultPassword123');
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteAccount();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
