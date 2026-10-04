import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';

void main() {
  group('UserProfile Model', () {
    test('serializes to and from Map correctly with English-only defaults', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'user-123',
        displayName: 'Aarav Patel',
        email: 'aarav@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        city: 'Ahmedabad',
        clubTag: 'endurance.amd',
        // V1 supports English only — language field defaults to 'en'
        language: 'en',
        units: DistanceUnit.kilometers,
        createdAt: now,
      );

      final map = profile.toMap();
      expect(map['id'], 'user-123');
      expect(map['display_name'], 'Aarav Patel');
      expect(map['language'], 'en');
      expect(map['units'], 'kilometers');

      final deserialized = UserProfile.fromMap(map, fallbackEmail: 'aarav@example.com');
      expect(deserialized.id, profile.id);
      expect(deserialized.displayName, profile.displayName);
      expect(deserialized.email, profile.email);
      expect(deserialized.city, profile.city);
      expect(deserialized.clubTag, profile.clubTag);
      expect(deserialized.language, 'en');
      expect(deserialized.units, DistanceUnit.kilometers);
    });

    test('fromMap treats missing language field as English', () {
      // Simulates a row from the database that predates V1 language field
      final map = {
        'id': 'user-999',
        'display_name': 'Legacy User',
        'created_at': DateTime.now().toIso8601String(),
        // 'language' key deliberately absent
      };
      final profile = UserProfile.fromMap(map);
      expect(profile.language, 'en');
    });

    test('fromMap with legacy Hindi code stores the raw value (DB compat)', () {
      // V1 stores 'en' for new users; legacy 'hi' or 'gu' rows may still
      // exist in the database. The model round-trips the value faithfully
      // (for DB backward-compat), but the Flutter runtime NEVER uses it to
      // switch locale — LocaleNotifier always returns Locale('en').
      final map = {
        'id': 'user-old-hi',
        'display_name': 'Old Hindi User',
        'language': 'hi',
        'created_at': DateTime.now().toIso8601String(),
      };
      final profile = UserProfile.fromMap(map);
      // Field is preserved for DB round-trip; the app UI ignores it.
      expect(profile.language, 'hi');
    });

    test('fromMap with legacy Gujarati code stores the raw value (DB compat)', () {
      final map = {
        'id': 'user-old-gu',
        'display_name': 'Old Gujarati User',
        'language': 'gu',
        'created_at': DateTime.now().toIso8601String(),
      };
      final profile = UserProfile.fromMap(map);
      // Field is preserved for DB round-trip; the app UI ignores it.
      expect(profile.language, 'gu');
    });

    test('supports copyWith updates', () {
      final profile = UserProfile(
        id: 'user-123',
        displayName: 'Old Name',
        createdAt: DateTime.now(),
      );

      final updated = profile.copyWith(
        displayName: 'New Name',
        units: DistanceUnit.miles,
      );

      expect(updated.displayName, 'New Name');
      expect(updated.units, DistanceUnit.miles);
      expect(updated.id, profile.id);
    });

    test('DistanceUnit correctly maps from string', () {
      expect(DistanceUnit.fromString('kilometers'), DistanceUnit.kilometers);
      expect(DistanceUnit.fromString('miles'), DistanceUnit.miles);
      expect(DistanceUnit.fromString('unknown'), DistanceUnit.kilometers);
      expect(DistanceUnit.fromString(null), DistanceUnit.kilometers);
    });
  });
}
