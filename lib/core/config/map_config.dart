
/// Map configuration for MapLibre integration
class MapConfig {
  /// Geoapify style URL for OSM Bright map
  /// Uses environment variable GEOAPIFY_MAP_KEY
  /// Build parity: flutter build apk --debug --dart-define=GEOAPIFY_MAP_KEY=<key>
  static String get styleUrl {
    const apiKey = String.fromEnvironment(
      'GEOAPIFY_MAP_KEY',
      defaultValue: '',
    );
    if (apiKey.isNotEmpty) {
      return 'https://maps.geoapify.com/v1/styles/osm-bright/style.json?apiKey=$apiKey';
    }
    // Fallback demo tiles style matching web base-map.tsx
    return 'https://demotiles.maplibre.org/style.json';
  }

  /// Whether a valid map key or style is present
  static bool get hasMapKey => styleUrl.isNotEmpty;

  /// Map attribution text
  static const String attribution = ' Geoapify ·  OpenMapTiles ·  OpenStreetMap contributors';

  /// Default initial zoom level
  static const double defaultZoom = 14.0;

  /// Minimum zoom level
  static const double minZoom = 3.0;

  /// Maximum zoom level
  static const double maxZoom = 19.0;

  /// Default center point (Kathmandu)
  static const double defaultLatitude = 27.7172;
  static const double defaultLongitude = 85.3240;
}
