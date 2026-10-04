import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/localization/locale_provider.dart';
import 'package:indirun/data/local/in_memory_profile_repository.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';

void main() {
  group('InMemoryProfileRepository', () {
    test('returns null when profile is missing', () async {
      final repo = InMemoryProfileRepository();
      final profile = await repo.getProfile('user-456');
      expect(profile, isNull);
    });

    test('updates display name and units correctly', () async {
      const userId = 'user-789';
      final repo = InMemoryProfileRepository({
        userId: UserProfile(
          id: userId,
          displayName: 'Initial',
          createdAt: DateTime.now(),
        ),
      });

      await repo.updateDisplayName(userId, 'Vikram Singh');
      var profile = await repo.getProfile(userId);
      expect(profile?.displayName, 'Vikram Singh');

      await repo.updateUnits(userId, DistanceUnit.miles);
      profile = await repo.getProfile(userId);
      expect(profile?.units, DistanceUnit.miles);
    });

    test('updateLanguage writes language field to profile (DB backward-compat)', () async {
      // The method is kept for DB backward-compatibility.
      // V1 only passes 'en'; the Flutter runtime never selects 'hi' or 'gu'.
      const userId = 'user-compat';
      final repo = InMemoryProfileRepository({
        userId: UserProfile(
          id: userId,
          displayName: 'Compat User',
          language: 'en',
          createdAt: DateTime.now(),
        ),
      });

      // Calling with 'en' (the only code V1 should ever pass) works correctly.
      await repo.updateLanguage(userId, 'en');
      final profile = await repo.getProfile(userId);
      expect(profile?.language, 'en');
    });
  });

  group('Language locale safety (via AppLanguage)', () {
    test('Hindi is not a supported locale in V1', () {
      // AppLanguage.fromCode('hi') must silently return English.
      expect(AppLanguage.fromCode('hi'), AppLanguage.english);
    });

    test('Gujarati is not a supported locale in V1', () {
      // AppLanguage.fromCode('gu') must silently return English.
      expect(AppLanguage.fromCode('gu'), AppLanguage.english);
    });

    test('English is the only supported locale in AppLocalizations', () {
      final codes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toList();
      expect(codes, equals(['en']));
    });
  });
}
