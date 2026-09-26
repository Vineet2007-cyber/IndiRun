abstract interface class AuthRepository {
  /// Repository interface for authentication.
  Stream<String?> get authStateChanges;
  String? get currentUserId;
  Future<void> signOut();
  Future<void> deleteAccount();
}
