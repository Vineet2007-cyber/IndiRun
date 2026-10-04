import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/gps_status.dart';
import '../domain/location_result.dart';
import '../domain/map_layer.dart';
import '../domain/pre_run_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pre-run notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Default fallback pace when no run history is available: 6 min/km.
const int _defaultPaceSecPerKm = 6 * 60;

class PreRunNotifier extends Notifier<PreRunState> {
  Timer? _searchingTimer;

  @override
  PreRunState build() {
    ref.onDispose(() => _searchingTimer?.cancel());
    _initMapLayer();
    _simulateGpsAcquisition();
    return const PreRunState();
  }

  // ── GPS ──────────────────────────────────────────────────────────────────

  void _simulateGpsAcquisition() {
    // After 15 s of searching, transition to ready (demo only).
    // Real impl will call location services.
    _searchingTimer = Timer(const Duration(seconds: 3), () {
      if (state.gpsStatus == GpsStatus.searching) {
        state = state.copyWith(gpsStatus: GpsStatus.ready);
      }
    });
  }

  /// Called from settings / OS callbacks in real implementation.
  void setGpsStatus(GpsStatus status) {
    _searchingTimer?.cancel();
    state = state.copyWith(gpsStatus: status);
  }

  // ── Destination ──────────────────────────────────────────────────────────

  void setDestination(LocationResult dest) {
    // Compute an estimated time using recent pace or default.
    final double dist = _estimateDistance(dest);
    final int avgPace = _recentAvgPaceSec();
    final int estMin = (dist * avgPace / 60).round().clamp(1, 9999);

    state = state.copyWith(
      destination: () => dest,
      voiceEnabled: false,
      routeDistanceKm: () => dist,
      estimatedMinutes: () => estMin,
    );
  }

  void clearDestination() {
    state = state.clearDestination();
  }

  // ── Map layer ─────────────────────────────────────────────────────────────

  Future<void> setMapLayer(MapLayer layer) async {
    state = state.copyWith(mapLayer: layer);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('map_layer', layer.prefValue);
  }

  Future<void> _initMapLayer() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('map_layer');
    final layer = MapLayer.fromPref(saved);
    state = state.copyWith(mapLayer: layer);
  }

  // ── Voice cues ────────────────────────────────────────────────────────────

  void setVoiceEnabled(bool enabled) {
    if (!state.hasRoute) return; // guard
    state = state.copyWith(voiceEnabled: enabled);
  }

  // ── Offline ───────────────────────────────────────────────────────────────

  void setOffline(bool offline) {
    state = state.copyWith(isOffline: offline);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Placeholder distance estimate (haversine not yet available at pre-run).
  /// Replaced by actual route distance once Maps SDK is integrated.
  double _estimateDistance(LocationResult dest) {
    // For demo purposes, return a static plausible distance.
    // Real impl: haversine(currentLat, currentLng, dest.lat, dest.lng).
    return 5.2;
  }

  int _recentAvgPaceSec() {
    // TODO(M4): read from run history repository.
    return _defaultPaceSecPerKm;
  }

  void reset() {
    _searchingTimer?.cancel();
    state = const PreRunState();
    _simulateGpsAcquisition();
  }
}

final preRunProvider =
    NotifierProvider<PreRunNotifier, PreRunState>(PreRunNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Location search notifier
// ─────────────────────────────────────────────────────────────────────────────

enum SearchPhase { idle, loading, results, empty, error, offline }

class SearchState {
  const SearchState({
    this.query = '',
    this.phase = SearchPhase.idle,
    this.results = const [],
    this.recentSearches = const [],
    this.errorMessage,
  });

  final String query;
  final SearchPhase phase;
  final List<LocationResult> results;
  final List<LocationResult> recentSearches;
  final String? errorMessage;

  SearchState copyWith({
    String? query,
    SearchPhase? phase,
    List<LocationResult>? results,
    List<LocationResult>? recentSearches,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      phase: phase ?? this.phase,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationSearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void onQueryChanged(String q, {required bool isOffline}) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      state = state.copyWith(query: q, phase: SearchPhase.idle, results: []);
      return;
    }

    state = state.copyWith(query: q, phase: SearchPhase.loading);

    if (isOffline) {
      state = state.copyWith(phase: SearchPhase.offline);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  void _search(String q) {
    // Demo implementation – returns static India-filtered results.
    // Real impl: call Nominatim / Google Places with countrycodes=in.
    final lower = q.toLowerCase();
    final mock = _mockResults.where(
      (r) => r.name.toLowerCase().contains(lower) ||
          r.subtitle.toLowerCase().contains(lower),
    ).toList();

    if (mock.isEmpty) {
      state = state.copyWith(phase: SearchPhase.empty, results: []);
    } else {
      state = state.copyWith(phase: SearchPhase.results, results: mock);
    }
  }

  void selectResult(LocationResult result) {
    final recent = [
      result,
      ...state.recentSearches.where((r) => r != result),
    ].take(5).toList();
    state = state.copyWith(
      recentSearches: recent,
      phase: SearchPhase.idle,
      query: '',
      results: [],
    );
  }

  void clear() {
    _debounce?.cancel();
    state = state.copyWith(query: '', phase: SearchPhase.idle, results: []);
  }
}

final locationSearchProvider =
    NotifierProvider<LocationSearchNotifier, SearchState>(
        LocationSearchNotifier.new);

/// Static demo data – India-scoped.
const _mockResults = [
  LocationResult(
    name: 'Sabarmati Riverfront',
    subtitle: 'Ahmedabad, Gujarat',
    lat: 23.0225,
    lng: 72.5714,
  ),
  LocationResult(
    name: 'Riverfront Park, Paldi',
    subtitle: 'Ahmedabad',
    lat: 23.0150,
    lng: 72.5710,
  ),
  LocationResult(
    name: 'Riverfront Garden Rd',
    subtitle: 'Ahmedabad',
    lat: 23.0200,
    lng: 72.5720,
  ),
  LocationResult(
    name: 'Lal Darwaja',
    subtitle: 'Ahmedabad, Gujarat',
    lat: 23.0262,
    lng: 72.5830,
  ),
  LocationResult(
    name: 'Vastrapur Lake',
    subtitle: 'Ahmedabad',
    lat: 23.0461,
    lng: 72.5286,
  ),
];
