import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_failure.dart';
import '../../features/profile/domain/user_profile.dart';
import '../repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient client;

  SupabaseProfileRepository({required this.client});

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserProfile.fromMap(
        response,
        fallbackEmail: client.auth.currentUser?.email,
      );
    } on PostgrestException catch (e) {
      throw DatabaseFailure(e.message, e);
    } catch (e) {
      throw DatabaseFailure('Failed to load profile', e);
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await client.from('profiles').upsert(profile.toMap());
    } on PostgrestException catch (e) {
      throw DatabaseFailure(e.message, e);
    } catch (e) {
      throw DatabaseFailure('Failed to update profile', e);
    }
  }

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    try {
      await client
          .from('profiles')
          .update({'display_name': displayName, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(e.message, e);
    } catch (e) {
      throw DatabaseFailure('Failed to update display name', e);
    }
  }

  @override
  Future<void> updateUnits(String userId, DistanceUnit units) async {
    try {
      await client
          .from('profiles')
          .update({'units': units.code, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(e.message, e);
    } catch (e) {
      throw DatabaseFailure('Failed to update distance units', e);
    }
  }

  @override
  Future<void> updateLanguage(String userId, String languageCode) async {
    try {
      await client
          .from('profiles')
          .update({'language': languageCode, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(e.message, e);
    } catch (e) {
      throw DatabaseFailure('Failed to update profile language', e);
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      await client.from('profiles').delete().eq('id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(e.message, e);
    } catch (e) {
      throw DatabaseFailure('Failed to delete profile', e);
    }
  }
}
