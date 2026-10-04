/// All GPS states from S14 GPS states.svg
enum GpsStatus {
  /// Actively searching for signal — Start disabled
  searching,

  /// Signal acquired but weak — Start allowed after confirmation dialog
  weak,

  /// Hardware GPS is turned off — Start blocked
  gpsOff,

  /// App location permission was denied — Start blocked
  permissionDenied,

  /// Good signal — Start fully enabled
  ready,
}

extension GpsStatusX on GpsStatus {
  bool get canStart => this == GpsStatus.ready || this == GpsStatus.weak;
  bool get isBlocked =>
      this == GpsStatus.searching ||
      this == GpsStatus.gpsOff ||
      this == GpsStatus.permissionDenied;
  bool get needsConfirmation => this == GpsStatus.weak;
}
