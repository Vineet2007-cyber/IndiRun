abstract interface class RunRepository {
  /// Local-first repository interface for run persistence and sync.
  Future<void> saveRun(Map<String, dynamic> runData);
  Future<Map<String, dynamic>?> getRunById(String runId);
  Future<List<Map<String, dynamic>>> getRunsHistory();
  Future<void> deleteRun(String runId);
  Future<void> syncPendingRuns();
}
