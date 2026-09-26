sealed class AppFailure {
  final String message;
  final dynamic cause;

  const AppFailure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network connection failed', super.cause]);
}

final class PermissionFailure extends AppFailure {
  final String? permission;
  const PermissionFailure([super.message = 'Required permission was denied', this.permission, super.cause]);
}

final class LocationFailure extends AppFailure {
  const LocationFailure([super.message = 'Location / GPS service error', super.cause]);
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Local database operation failed', super.cause]);
}

final class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Authentication failed', super.cause]);
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred', super.cause]);
}
