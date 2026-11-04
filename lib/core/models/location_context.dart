import 'dart:convert';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';

/// Normalized domain location context model.
/// Unifies display labeling, physical geographic coordinates, and administrative
/// hierarchies (locality, municipality, district, province) without conflating them.
class LocationContext {
  final String displayName;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? locality;
  final String? municipality;
  final String? district;
  final String? province;

  const LocationContext({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 25.0,
    this.locality,
    this.municipality,
    this.district,
    this.province,
  });

  /// Factory from a PlaceSuggestion returned by autocomplete or reverse geocode
  factory LocationContext.fromPlaceSuggestion(
    PlaceSuggestion place, {
    double radiusKm = 25.0,
  }) {
    return LocationContext(
      displayName: place.formatted.isNotEmpty ? place.formatted : place.name,
      latitude: place.lat,
      longitude: place.lon,
      radiusKm: radiusKm,
      locality: place.name,
      district: place.district,
    );
  }

  /// Converts to PlaceSuggestion for compatibility with existing modals and components
  PlaceSuggestion toPlaceSuggestion() {
    return PlaceSuggestion(
      formatted: displayName,
      name: locality ?? displayName,
      district: district,
      lat: latitude,
      lon: longitude,
      confidence: 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'latitude': latitude,
    'longitude': longitude,
    'radiusKm': radiusKm,
    'locality': locality,
    'municipality': municipality,
    'district': district,
    'province': province,
  };

  factory LocationContext.fromJson(Map<String, dynamic> json) {
    return LocationContext(
      displayName: json['displayName'] as String? ?? 'Kathmandu Valley',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.7172,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 85.3240,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 25.0,
      locality: json['locality'] as String?,
      municipality: json['municipality'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
    );
  }

  LocationContext copyWith({
    String? displayName,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? locality,
    String? municipality,
    String? district,
    String? province,
  }) {
    return LocationContext(
      displayName: displayName ?? this.displayName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      locality: locality ?? this.locality,
      municipality: municipality ?? this.municipality,
      district: district ?? this.district,
      province: province ?? this.province,
    );
  }

  static const defaultKathmandu = LocationContext(
    displayName: 'Kathmandu Valley',
    latitude: 27.7172,
    longitude: 85.3240,
    radiusKm: 25.0,
    district: 'Kathmandu',
  );
}

