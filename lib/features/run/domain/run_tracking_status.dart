/// Pure Dart domain model representing the run tracking lifecycle states
/// as defined in the Software Build Plan.
enum RunTrackingStatus {
  idle,
  preparing,
  running,
  paused,
  finishing,
  completed,
  discarded,
  recovering;

  bool get isActive => this == RunTrackingStatus.running || this == RunTrackingStatus.paused;
  bool get isPaused => this == RunTrackingStatus.paused;
  bool get isRunning => this == RunTrackingStatus.running;
}
