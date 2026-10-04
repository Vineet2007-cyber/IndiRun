/// Validator encapsulating IndiRun username rules:
/// - 3–20 characters
/// - Lowercase letters, numbers, underscore, dot
/// - Cannot start with dot
/// - Cannot end with dot
/// - Case-insensitive uniqueness
/// - Reserved/offensive usernames rejected
abstract final class UsernameValidator {
  static final RegExp _allowedChars = RegExp(r'^[a-z0-9_.]+$');

  static const Set<String> reservedUsernames = {
    'admin',
    'administrator',
    'indirun',
    'official',
    'support',
    'help',
    'root',
    'moderator',
    'system',
    'null',
    'undefined',
    'test',
    'guest',
    'user',
    'superuser',
    'run',
    'runner',
    'api',
    'dev',
    'developer',
    'staff',
    'team',
  };

  /// Returns null if valid, or a user-facing error message if invalid.
  static String? validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (trimmed.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (trimmed.length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    if (trimmed.startsWith('.')) {
      return 'Username cannot start with a dot';
    }
    if (trimmed.endsWith('.')) {
      return 'Username cannot end with a dot';
    }
    if (!_allowedChars.hasMatch(trimmed.toLowerCase())) {
      return 'Only lowercase letters, numbers, _ and . allowed';
    }
    if (reservedUsernames.contains(trimmed.toLowerCase())) {
      return 'This username is reserved';
    }
    return null;
  }

  /// Calculates password strength:
  /// - 0: Empty
  /// - 1: Weak (<8 characters or no number)
  /// - 2: Medium (8+ characters, 1+ number)
  /// - 3: Strong (8+ characters, 1+ number, and uppercase or special character)
  static int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 8) return 1;

    final hasNumber = password.contains(RegExp(r'[0-9]'));
    if (!hasNumber) return 1;

    final hasUpperOrSpecial = password.contains(RegExp(r'[A-Z!@#$%^&*(),.?":{}|<>]'));
    if (hasUpperOrSpecial && password.length >= 10) {
      return 3;
    }
    return 2;
  }

  static String passwordStrengthLabel(int strength) {
    switch (strength) {
      case 1:
        return 'Weak: 8+ characters, 1 number';
      case 2:
        return 'Medium: 8+ characters, 1 number';
      case 3:
        return 'Strong: Great password!';
      default:
        return '8+ characters, 1 number';
    }
  }
}
