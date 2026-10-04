/// A resolved geographic location with display name.
class LocationResult {
  const LocationResult({
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String subtitle;
  final double lat;
  final double lng;

  String get fullName => subtitle.isEmpty ? name : '$name, $subtitle';

  @override
  bool operator ==(Object other) =>
      other is LocationResult && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}
