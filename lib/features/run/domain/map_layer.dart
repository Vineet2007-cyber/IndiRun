/// Map display style – persisted in SharedPreferences.
enum MapLayer {
  defaultLayer,
  satellite,
  publicTransport;

  String get label => switch (this) {
        MapLayer.defaultLayer => 'Default',
        MapLayer.satellite => 'Satellite',
        MapLayer.publicTransport => 'Public transport',
      };

  String get prefValue => name;

  static MapLayer fromPref(String? value) => MapLayer.values.firstWhere(
        (l) => l.name == value,
        orElse: () => MapLayer.defaultLayer,
      );
}
