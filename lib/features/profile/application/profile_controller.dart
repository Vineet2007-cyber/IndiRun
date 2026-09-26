import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../domain/user_profile.dart';
import '../../auth/application/auth_controller.dart';

class ProfileController extends AsyncNotifier<UserProfile?> {
  late final ProfileRepository _repository;

  @override
  Future<UserProfile?> build() async {
    _repository = ref.watch(profileRepositoryProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      return null;
    }

    try {
      final profile = await _repository.getProfile(user.id);
      if (profile != null) {
        return profile;
      }

      // If no profile exists yet in remote, provision from auth details
      final initialProfile = UserProfile(
        id: user.id,
        displayName: user.displayName ?? 'Runner',
        email: user.email,
        avatarUrl: user.avatarUrl,
        language: 'en',
        units: DistanceUnit.kilometers,
        createdAt: DateTime.now(),
      );

      // Async write to persist, but don't block display
      _repository.updateProfile(initialProfile).ignore();
      return initialProfile;
    } catch (_) {
      // Graceful fallback to initial profile model with user identity
      return UserProfile(
        id: user.id,
        displayName: user.displayName ?? 'Runner',
        email: user.email,
        avatarUrl: user.avatarUrl,
        language: 'en',
        units: DistanceUnit.kilometers,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<bool> updateDisplayName(String displayName) async {
    final current = state.value;
    if (current == null) return false;

    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return false;

    final updated = current.copyWith(displayName: trimmed);
    state = AsyncData(updated);

    try {
      await _repository.updateDisplayName(current.id, trimmed);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(current); // revert on failure
      return false;
    }
  }

  Future<void> updateUnits(DistanceUnit units) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(units: units);
    state = AsyncData(updated);

    try {
      await _repository.updateUnits(current.id, units);
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(current);
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(language: languageCode);
    state = AsyncData(updated);

    try {
      await _repository.updateLanguage(current.id, languageCode);
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(current);
    }
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(() {
  return ProfileController();
});
