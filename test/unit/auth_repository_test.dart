import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/data/local/in_memory_auth_repository.dart';

void main() {
  group('InMemoryAuthRepository', () {
    test('initializes as unauthenticated by default', () {
      final repo = InMemoryAuthRepository();
      expect(repo.currentUser, isNull);
      expect(repo.isAuthenticated, isFalse);
    });

    test('sign in with Google sets active user and emits state', () async {
      final repo = InMemoryAuthRepository();
      expectLater(
        repo.authStateChanges,
        emits(predicate((user) => user != null && repo.currentUser?.id == 'demo-user-id')),
      );

      await repo.signInWithGoogle();
      expect(repo.isAuthenticated, isTrue);
      expect(repo.currentUser?.displayName, 'IndiRunner');
    });

    test('sign out clears user and emits null', () async {
      final repo = InMemoryAuthRepository();
      await repo.signInWithGoogle();
      expect(repo.isAuthenticated, isTrue);

      expectLater(repo.authStateChanges, emits(isNull));
      await repo.signOut();
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentUser, isNull);
    });

    test('delete account clears session', () async {
      final repo = InMemoryAuthRepository();
      await repo.signInWithGoogle();
      expect(repo.isAuthenticated, isTrue);

      await repo.deleteAccount();
      expect(repo.isAuthenticated, isFalse);
      expect(repo.currentUser, isNull);
    });
  });
}
