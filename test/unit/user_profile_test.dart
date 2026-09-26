import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';

void main() {
  group('UserProfile Model', () {
    test('serializes to and from Map correctly', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'user-123',
        displayName: 'Aarav Patel',
        email: 'aarav@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        city: 'Ahmedabad',
        clubTag: 'endurance.amd',
        language: 'gu',
        units: DistanceUnit.kilometers,
        createdAt: now,
      );

      final map = profile.toMap();
      expect(map['id'], 'user-123');
      expect(map['display_name'], 'Aarav Patel');
      expect(map['language'], 'gu');
      expect(map['units'], 'kilometers');

      final deserialized = UserProfile.fromMap(map, fallbackEmail: 'aarav@example.com');
      expect(deserialized.id, profile.id);
      expect(deserialized.displayName, profile.displayName);
      expect(deserialized.email, profile.email);
      expect(deserialized.city, profile.city);
      expect(deserialized.clubTag, profile.clubTag);
      expect(deserialized.language, 'gu');
      expect(deserialized.units, DistanceUnit.kilometers);
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
