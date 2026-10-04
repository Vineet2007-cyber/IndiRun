import '../../features/profile/domain/user_profile.dart';

abstract interface class ProfileRepository {
  /// Fetches the user profile by user ID.
  Future<UserProfile?> getProfile(String userId);

  /// Saves or updates the user profile in the persistent store.
  Future<void> updateProfile(UserProfile profile);

  /// Updates user display name.
  Future<void> updateDisplayName(String userId, String displayName);

  /// Updates distance units preference (kilometers / miles).
  Future<void> updateUnits(String userId, DistanceUnit units);

  /// Updates user language preference code. V1 supports 'en' only.
  Future<void> updateLanguage(String userId, String languageCode);

  /// Deletes the user profile record.
  Future<void> deleteProfile(String userId);
}
