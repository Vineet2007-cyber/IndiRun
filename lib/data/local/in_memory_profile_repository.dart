import '../../features/profile/domain/user_profile.dart';
import '../repositories/profile_repository.dart';

class InMemoryProfileRepository implements ProfileRepository {
  final Map<String, UserProfile> _profiles = {};

  InMemoryProfileRepository([Map<String, UserProfile>? initial]) {
    if (initial != null) {
      _profiles.addAll(initial);
    }
  }

  @override
  Future<UserProfile?> getProfile(String userId) async {
    return _profiles[userId];
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _profiles[profile.id] = profile;
  }

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    final existing = await getProfile(userId);
    if (existing != null) {
      _profiles[userId] = existing.copyWith(displayName: displayName);
    }
  }

  @override
  Future<void> updateUnits(String userId, DistanceUnit units) async {
    final existing = await getProfile(userId);
    if (existing != null) {
      _profiles[userId] = existing.copyWith(units: units);
    }
  }

  @override
  Future<void> updateLanguage(String userId, String languageCode) async {
    final existing = await getProfile(userId);
    if (existing != null) {
      _profiles[userId] = existing.copyWith(language: languageCode);
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    _profiles.remove(userId);
  }
}
