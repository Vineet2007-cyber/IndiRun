import 'gps_status.dart';
import 'location_result.dart';
import 'map_layer.dart';

/// Immutable state for the pre-run setup screen (S09/S10).
class PreRunState {
  const PreRunState({
    this.gpsStatus = GpsStatus.searching,
    this.destination,
    this.mapLayer = MapLayer.defaultLayer,
    this.voiceEnabled = false,
    this.routeDistanceKm,
    this.estimatedMinutes,
    this.isOffline = false,
  });

  final GpsStatus gpsStatus;

  /// Null → free run (no destination set).
  final LocationResult? destination;

  final MapLayer mapLayer;

  /// Voice cues are only functional when a destination is set.
  final bool voiceEnabled;

  /// Only populated once both start + destination are known.
  final double? routeDistanceKm;
  final int? estimatedMinutes;

  final bool isOffline;

  bool get hasRoute => destination != null;
  bool get hasDistanceInfo => routeDistanceKm != null && estimatedMinutes != null;

  PreRunState copyWith({
    GpsStatus? gpsStatus,
    LocationResult? Function()? destination,
    MapLayer? mapLayer,
    bool? voiceEnabled,
    double? Function()? routeDistanceKm,
    int? Function()? estimatedMinutes,
    bool? isOffline,
  }) {
    return PreRunState(
      gpsStatus: gpsStatus ?? this.gpsStatus,
      destination: destination != null ? destination() : this.destination,
      mapLayer: mapLayer ?? this.mapLayer,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      routeDistanceKm: routeDistanceKm != null ? routeDistanceKm() : this.routeDistanceKm,
      estimatedMinutes: estimatedMinutes != null ? estimatedMinutes() : this.estimatedMinutes,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  PreRunState clearDestination() {
    return PreRunState(
      gpsStatus: gpsStatus,
      destination: null,
      mapLayer: mapLayer,
      voiceEnabled: false,
      routeDistanceKm: null,
      estimatedMinutes: null,
      isOffline: isOffline,
    );
  }
}
