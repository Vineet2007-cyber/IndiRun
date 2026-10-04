/// V1 run data model
class RunModel {
  const RunModel({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.distanceKm,
    required this.durationSeconds,
    required this.routePoints,
    this.label,
    this.avgPaceSec,
    this.elevGainM,
    this.isSynced = false,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceKm;
  final int durationSeconds;
  final List<Map<String, double>> routePoints; // [{lat, lng}]
  final String? label;
  final int? avgPaceSec; // seconds per km
  final double? elevGainM;
  final bool isSynced;

  RunModel copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    double? distanceKm,
    int? durationSeconds,
    List<Map<String, double>>? routePoints,
    String? label,
    int? avgPaceSec,
    double? elevGainM,
    bool? isSynced,
  }) {
    return RunModel(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      routePoints: routePoints ?? this.routePoints,
      label: label ?? this.label,
      avgPaceSec: avgPaceSec ?? this.avgPaceSec,
      elevGainM: elevGainM ?? this.elevGainM,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Formatted duration, e.g. "29:40"
  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Formatted pace, e.g. "5:55 /km"
  String get avgPaceFormatted {
    final sec = avgPaceSec ??
        (distanceKm > 0 ? (durationSeconds / distanceKm).round() : 0);
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Human-readable label: date + ordinal, e.g. "Tue, 29 Sep"
  String get dateLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = startedAt;
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }
}
