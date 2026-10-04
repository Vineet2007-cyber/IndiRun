import 'dart:async';
import '../../../core/errors/app_failure.dart';
import '../../features/auth/domain/username_validator.dart';
import '../repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  // Local simulated accounts
  final Set<String> _takenUsernames = {'runner', 'indirunner', 'pro_runner'};
  final Map<String, String> _passwords = {
    'runner': 'Password123',
    'indirunner': 'Password123',
    'pro_runner': 'Password123',
  };
  final Map<String, String> _emails = {
    'runner': 'runner@indirun.app',
    'indirunner': 'indi@indirun.app',
    'pro_runner': 'pro@indirun.app',
  };

  InMemoryAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<void> signInWithGoogle({String? redirectTo}) async {
    // Identity verification only — user does not get an automatic username
    _currentUser = const AuthUser(
      id: 'demo-user-id',
      email: 'runner@indirun.app',
      displayName: 'IndiRunner',
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithUsernameAndPassword(String username, String password) async {
    final lower = username.trim().toLowerCase();
    // Allow demo runner or previously registered credentials
    if (_passwords.containsKey(lower)) {
      if (_passwords[lower] != password) {
        throw const AuthFailure('Invalid username or password');
      }
      _currentUser = AuthUser(
        id: 'user-$lower',
        email: _emails[lower] ?? '$lower@indirun.app',
        displayName: lower,
      );
      _controller.add(_currentUser);
      return;
    }

    // Default test fallback for common tests: allow any non-empty password for mock users
    if (password.length >= 6) {
      _currentUser = AuthUser(
        id: 'user-$lower',
        email: '$lower@indirun.app',
        displayName: lower,
      );
      _controller.add(_currentUser);
      return;
    }

    throw const AuthFailure('Invalid username or password');
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final error = UsernameValidator.validate(username);
    if (error != null) return false;
    final lower = username.trim().toLowerCase();
    return !_takenUsernames.contains(lower);
  }

  @override
  Future<void> completeSignUp({required String username, required String password}) async {
    final lower = username.trim().toLowerCase();
    _takenUsernames.add(lower);
    _passwords[lower] = password;
    final email = '$lower@gmail.com';
    _emails[lower] = email;

    _currentUser = AuthUser(
      id: 'user-$lower',
      email: email,
      displayName: lower,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<String?> sendPasswordReset(String username) async {
    final lower = username.trim().toLowerCase();
    final email = _emails[lower] ?? '${lower.isNotEmpty ? lower[0] : 'r'}***@gmail.com';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts.length > 1 ? parts[1] : 'gmail.com';
    final maskedName = name.length > 1 ? '${name[0]}***' : 'r***';
    return '$maskedName@$domain';
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
