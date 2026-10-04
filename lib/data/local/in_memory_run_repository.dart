import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/run_repository.dart';

/// Local-first repository for persisting runs offline.
/// Backed by in-memory cache and SharedPreferences for persistence across restarts.
class InMemoryRunRepository implements RunRepository {
  InMemoryRunRepository({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;
  final Map<String, Map<String, dynamic>> _runs = {};
  static const _storageKey = 'indirun_local_runs';

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final id = item['id'] as String?;
            if (id != null) {
              _runs[id] = item;
            }
          }
        }
      } catch (_) {
        // Fallback gracefully on corrupted data
      }
    }
  }

  @override
  Future<void> saveRun(Map<String, dynamic> runData) async {
    final id = runData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    _runs[id] = Map<String, dynamic>.from(runData);
    await _persist();
  }

  @override
  Future<Map<String, dynamic>?> getRunById(String runId) async {
    return _runs[runId];
  }

  @override
  Future<List<Map<String, dynamic>>> getRunsHistory() async {
    final list = _runs.values.toList();
    // Sort descending by startedAt
    list.sort((a, b) {
      final aDate = a['startedAt']?.toString() ?? '';
      final bDate = b['startedAt']?.toString() ?? '';
      return bDate.compareTo(aDate);
    });
    return list;
  }

  @override
  Future<void> deleteRun(String runId) async {
    _runs.remove(runId);
    await _persist();
  }

  @override
  Future<void> syncPendingRuns() async {
    // V1 is offline-first local persistence
  }

  Future<void> _persist() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (_) {
        return;
      }
    }
    final raw = jsonEncode(_runs.values.toList());
    await _prefs?.setString(_storageKey, raw);
  }
}
