import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';

void main() {
  group('Supabase Profile Data Mapping', () {
    test('UserProfile deserializes new Supabase row with English language', () {
      // New V1 users always have language = 'en' in the database.
      final supabaseRow = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'display_name': 'Rohit Kumar',
        'avatar_url': 'https://images.example.com/avatar.png',
        'city': 'Surat',
        'club_tag': 'surat.runners',
        'language': 'en',
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
      expect(profile.language, 'en');
      expect(profile.units, DistanceUnit.kilometers);
    });

    test('UserProfile deserializes legacy Supabase row with "gu" (DB backward-compat)', () {
      // Pre-V1 rows may have language = 'gu'. The model round-trips the
      // raw value for DB compatibility. The Flutter runtime NEVER uses
      // this field to switch the UI language — LocaleNotifier always returns
      // Locale('en') regardless.
      final supabaseRow = {
        'id': 'legacy-gu-user',
        'display_name': 'Dhruv Shah',
        'language': 'gu',
        'units': 'kilometers',
        'created_at': '2025-06-01T10:00:00.000Z',
      };

      final profile = UserProfile.fromMap(supabaseRow);
      // DB value preserved for round-trip; app UI shows English.
      expect(profile.language, 'gu');
    });

    test('UserProfile deserializes legacy Supabase row with "hi" (DB backward-compat)', () {
      // Pre-V1 rows may have language = 'hi'. Same policy as 'gu'.
      final supabaseRow = {
        'id': 'legacy-hi-user',
        'display_name': 'Rahul Verma',
        'language': 'hi',
        'units': 'kilometers',
        'created_at': '2025-06-01T10:00:00.000Z',
      };

      final profile = UserProfile.fromMap(supabaseRow);
      // DB value preserved for round-trip; app UI shows English.
      expect(profile.language, 'hi');
    });

    test('UserProfile correctly serializes new V1 profile to Supabase row format', () {
      final profile = UserProfile(
        id: 'u-123',
        displayName: 'Priya Patel',
        email: 'priya@example.com',
        avatarUrl: null,
        city: 'Vadodara',
        clubTag: null,
        language: 'en', // V1 always writes 'en' for new users
        units: DistanceUnit.miles,
        createdAt: DateTime(2026, 9, 26),
      );

      final map = profile.toMap();
      expect(map['id'], 'u-123');
      expect(map['display_name'], 'Priya Patel');
      expect(map['language'], 'en');
      expect(map['units'], 'miles');
      expect(map['city'], 'Vadodara');
      expect(map.containsKey('updated_at'), isTrue);
    });
  });
}
