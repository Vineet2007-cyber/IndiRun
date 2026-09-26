import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../../core/errors/app_failure.dart';
import '../repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient client;

  SupabaseAuthRepository({required this.client});

  AuthUser _mapUser(User user) {
    final meta = user.userMetadata ?? {};
    final displayName = (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        (user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'Runner');

    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: displayName,
      avatarUrl: meta['avatar_url'] as String?,
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return client.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  @override
  AuthUser? get currentUser {
    final user = client.auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  bool get isAuthenticated => client.auth.currentSession != null;

  @override
  Future<void> signInWithGoogle({String? redirectTo}) async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo ?? 'indirun://login-callback',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e);
    } catch (e) {
      throw AuthFailure('Failed to sign in with Google', e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e);
    } catch (e) {
      throw AuthFailure('Failed to sign out', e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;

    try {
      // 1. Delete application profile record (enforced by RLS)
      await client.from('profiles').delete().eq('id', user.id);

      // 2. If an RPC for secure self-deletion is configured on backend, trigger it
      try {
        await client.rpc('delete_user_account');
      } catch (_) {
        // RPC might not be provisioned yet; fallback to logging out
      }

      // 3. Clear auth session
      await client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e);
    } catch (e) {
      throw AuthFailure('Failed to delete account', e);
    }
  }
}
