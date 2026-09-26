import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/data/local/in_memory_profile_repository.dart';
import 'package:indirun/features/profile/domain/user_profile.dart';

void main() {
  group('InMemoryProfileRepository', () {
    test('returns null when profile is missing', () async {
      final repo = InMemoryProfileRepository();
      final profile = await repo.getProfile('user-456');
      expect(profile, isNull);
    });

    test('updates display name, language, and units correctly', () async {
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

      await repo.updateLanguage(userId, 'hi');
      profile = await repo.getProfile(userId);
      expect(profile?.language, 'hi');

      await repo.updateUnits(userId, DistanceUnit.miles);
      profile = await repo.getProfile(userId);
      expect(profile?.units, DistanceUnit.miles);
    });
  });
}
