import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/data/repositories/auth_repository.dart';
import 'package:indirun/features/auth/application/auth_state.dart';

void main() {
  group('AuthState', () {
    test('initial state has initializing status and no user', () {
      const state = AuthState.initial();
      expect(state.status, AuthStatus.initializing);
      expect(state.user, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isInitializing, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('authenticated state maps user correctly', () {
      const user = AuthUser(id: 'u1', email: 'test@example.com', displayName: 'Tester');
      const state = AuthState.authenticated(user);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, user);
      expect(state.isAuthenticated, isTrue);
      expect(state.isInitializing, isFalse);
    });

    test('unauthenticated state reflects signed-out status', () {
      const state = AuthState.unauthenticated();
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
      expect(state.isAuthenticated, isFalse);
    });

    test('error state reflects failure message', () {
      const state = AuthState.error('Network error');
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Network error');
      expect(state.isAuthenticated, isFalse);
    });
  });
}
