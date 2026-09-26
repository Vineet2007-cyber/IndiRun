import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/config_provider.dart';
import '../local/in_memory_auth_repository.dart';
import '../local/in_memory_profile_repository.dart';
import '../remote/supabase_auth_repository.dart';
import '../remote/supabase_profile_repository.dart';
import 'auth_repository.dart';
import 'profile_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (config.isSupabaseConfigured) {
    try {
      final client = Supabase.instance.client;
      return SupabaseAuthRepository(client: client);
    } catch (_) {
      // Supabase instance not initialized yet, fall back gracefully
    }
  }

  return InMemoryAuthRepository();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  if (config.isSupabaseConfigured) {
    try {
      final client = Supabase.instance.client;
      return SupabaseProfileRepository(client: client);
    } catch (_) {
      // Supabase instance not initialized yet, fall back gracefully
    }
  }

  return InMemoryProfileRepository();
});
