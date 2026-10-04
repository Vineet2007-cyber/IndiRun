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
  Future<void> signInWithUsernameAndPassword(String username, String password) async {
    try {
      final email = username.contains('@') ? username : '$username@indirun.app';
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e);
    } catch (e) {
      throw AuthFailure('Authentication failed', e);
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final clean = username.trim().toLowerCase();
      final res = await client
          .from('profiles')
          .select('id')
          .ilike('username', clean)
          .maybeSingle();
      return res == null;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> completeSignUp({required String username, required String password}) async {
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        await client.from('profiles').upsert({
          'id': user.id,
          'username': username.trim().toLowerCase(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e);
    } catch (e) {
      throw AuthFailure('Failed to set username', e);
    }
  }

  @override
  Future<String?> sendPasswordReset(String username) async {
    try {
      final email = username.contains('@') ? username : '$username@indirun.app';
      await client.auth.resetPasswordForEmail(email);
      final parts = email.split('@');
      final name = parts[0];
      final domain = parts.length > 1 ? parts[1] : 'gmail.com';
      final masked = name.length > 1 ? '${name[0]}***' : 'r***';
      return '$masked@$domain';
    } catch (_) {
      // Do not reveal whether user exists
      return '${username.isNotEmpty ? username[0] : 'r'}***@gmail.com';
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
