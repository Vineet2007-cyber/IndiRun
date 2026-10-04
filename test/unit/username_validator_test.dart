import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/auth/domain/username_validator.dart';

void main() {
  group('UsernameValidator', () {
    test('rejects empty username', () {
      expect(UsernameValidator.validate(''), 'Username is required');
      expect(UsernameValidator.validate('   '), 'Username is required');
    });

    test('rejects usernames shorter than 3 characters', () {
      expect(UsernameValidator.validate('ab'), 'Username must be at least 3 characters');
      expect(UsernameValidator.validate('a'), 'Username must be at least 3 characters');
    });

    test('rejects usernames longer than 20 characters', () {
      expect(
        UsernameValidator.validate('a_very_long_username_over_20_chars'),
        'Username cannot exceed 20 characters',
      );
    });

    test('rejects usernames starting or ending with a dot', () {
      expect(UsernameValidator.validate('.runner'), 'Username cannot start with a dot');
      expect(UsernameValidator.validate('runner.'), 'Username cannot end with a dot');
    });

    test('rejects invalid characters', () {
      expect(
        UsernameValidator.validate('runner!'),
        'Only lowercase letters, numbers, _ and . allowed',
      );
      expect(
        UsernameValidator.validate('runner@123'),
        'Only lowercase letters, numbers, _ and . allowed',
      );
      expect(
        UsernameValidator.validate('runner-fast'),
        'Only lowercase letters, numbers, _ and . allowed',
      );
    });

    test('rejects reserved and offensive usernames case-insensitively', () {
      expect(UsernameValidator.validate('admin'), 'This username is reserved');
      expect(UsernameValidator.validate('ADMIN'), 'This username is reserved');
      expect(UsernameValidator.validate('indirun'), 'This username is reserved');
      expect(UsernameValidator.validate('IndiRun'), 'This username is reserved');
      expect(UsernameValidator.validate('support'), 'This username is reserved');
      expect(UsernameValidator.validate('root'), 'This username is reserved');
    });

    test('accepts valid usernames', () {
      expect(UsernameValidator.validate('cool_runner_07'), isNull);
      expect(UsernameValidator.validate('runner.123'), isNull);
      expect(UsernameValidator.validate('fast_pace'), isNull);
      expect(UsernameValidator.validate('marathoner'), isNull);
    });

    test('calculates password strength accurately', () {
      expect(UsernameValidator.calculatePasswordStrength(''), 0);
      expect(UsernameValidator.calculatePasswordStrength('short'), 1);
      expect(UsernameValidator.calculatePasswordStrength('password'), 1); // No number
      expect(UsernameValidator.calculatePasswordStrength('password1'), 2); // 8+ chars and 1 number
      expect(UsernameValidator.calculatePasswordStrength('Password123!'), 3); // 10+ chars, number, uppercase, special
    });
  });
}
