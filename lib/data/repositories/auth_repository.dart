class AuthUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, email);
}

abstract interface class AuthRepository {
  /// Stream of authentication state changes. Emits null when signed out.
  Stream<AuthUser?> get authStateChanges;

  /// Currently authenticated user, or null if unauthenticated.
  AuthUser? get currentUser;

  /// Whether a user session is currently active.
  bool get isAuthenticated => currentUser != null;

  /// Initiates Google OAuth authentication flow.
  Future<void> signInWithGoogle({String? redirectTo});

  /// Signs in with username and password.
  Future<void> signInWithUsernameAndPassword(String username, String password);

  /// Checks if a username is available.
  Future<bool> isUsernameAvailable(String username);

  /// Completes sign-up with chosen username and password.
  Future<void> completeSignUp({
    required String username,
    required String password,
  });

  /// Sends a password reset link for the given username. Returns masked email hint.
  Future<String?> sendPasswordReset(String username);

  /// Terminates current user session.
  Future<void> signOut();

  /// Deletes the current user profile and triggers account deletion.
  Future<void> deleteAccount();
}
