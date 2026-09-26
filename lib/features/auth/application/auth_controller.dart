import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/config_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _subscription;

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
    final effectiveRedirect = redirectTo ?? ref.read(appConfigProvider).oauthRedirectUrl;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signInWithGoogle(redirectTo: effectiveRedirect);
      // OAuth flow initiates; auth state change will be emitted via stream
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
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

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
