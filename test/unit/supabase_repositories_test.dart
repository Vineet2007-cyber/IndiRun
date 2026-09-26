import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';

void main() {
  group('Supabase Profile Data Mapping', () {
    test('UserProfile correctly deserializes Supabase profiles row', () {
      final supabaseRow = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'display_name': 'Rohit Kumar',
        'avatar_url': 'https://images.example.com/avatar.png',
        'city': 'Surat',
        'club_tag': 'surat.runners',
        'language': 'gu',
        'units': 'kilometers',
        'created_at': '2026-09-26T10:00:00.000Z',
        'updated_at': '2026-09-26T12:00:00.000Z',
      };

      final profile = UserProfile.fromMap(supabaseRow, fallbackEmail: 'rohit@example.com');
      expect(profile.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(profile.displayName, 'Rohit Kumar');
      expect(profile.email, 'rohit@example.com');
      expect(profile.avatarUrl, 'https://images.example.com/avatar.png');
      expect(profile.city, 'Surat');
      expect(profile.clubTag, 'surat.runners');
      expect(profile.language, 'gu');
      expect(profile.units, DistanceUnit.kilometers);
    });

    test('UserProfile correctly serializes to Supabase profiles row format', () {
      final profile = UserProfile(
        id: 'u-123',
        displayName: 'Priya Patel',
        email: 'priya@example.com',
        avatarUrl: null,
        city: 'Vadodara',
        clubTag: null,
        language: 'hi',
        units: DistanceUnit.miles,
        createdAt: DateTime(2026, 9, 26),
      );

      final map = profile.toMap();
      expect(map['id'], 'u-123');
      expect(map['display_name'], 'Priya Patel');
      expect(map['language'], 'hi');
      expect(map['units'], 'miles');
      expect(map['city'], 'Vadodara');
      expect(map.containsKey('updated_at'), isTrue);
    });
  });
}
