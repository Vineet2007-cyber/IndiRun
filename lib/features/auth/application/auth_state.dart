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

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  const AuthState.initial()
      : status = AuthStatus.initializing,
        user = null,
        errorMessage = null,
        isLoading = false;

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null,
        isLoading = false;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null,
        isLoading = false;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message,
        isLoading = false;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isInitializing => status == AuthStatus.initializing;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
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
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(status, user, errorMessage, isLoading);
}
