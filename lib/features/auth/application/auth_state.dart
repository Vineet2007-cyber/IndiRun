import '../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initializing,
  authenticated,
  unauthenticated,
  error;

  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isInitializing => this == AuthStatus.initializing;
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isLoading;
  final int failedLoginAttempts;
  final DateTime? lockoutUntil;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.failedLoginAttempts = 0,
    this.lockoutUntil,
  });

  const AuthState.initial()
      : status = AuthStatus.initializing,
        user = null,
        errorMessage = null,
        isLoading = false,
        failedLoginAttempts = 0,
        lockoutUntil = null;

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null,
        isLoading = false,
        failedLoginAttempts = 0,
        lockoutUntil = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null,
        isLoading = false,
        failedLoginAttempts = 0,
        lockoutUntil = null;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message,
        isLoading = false,
        failedLoginAttempts = 0,
        lockoutUntil = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isInitializing => status == AuthStatus.initializing;

  bool get isLockedOut =>
      lockoutUntil != null && DateTime.now().isBefore(lockoutUntil!);

  int get remainingLockoutSeconds {
    if (!isLockedOut) return 0;
    return lockoutUntil!.difference(DateTime.now()).inSeconds + 1;
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool? isLoading,
    int? failedLoginAttempts,
    DateTime? lockoutUntil,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage &&
          isLoading == other.isLoading &&
          failedLoginAttempts == other.failedLoginAttempts &&
          lockoutUntil == other.lockoutUntil;

  @override
  int get hashCode => Object.hash(
        status,
        user,
        errorMessage,
        isLoading,
        failedLoginAttempts,
        lockoutUntil,
      );
}
