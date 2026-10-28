import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';

/// Persistent service that stores and retrieves the user's preferred location
/// across application restarts.
@lazySingleton
class UserLocationService {
  static const _storageKey = 'offer_nepal_user_location_pref';

  final FlutterSecureStorage _secureStorage;
  PlaceSuggestion? _cachedPlace;

  UserLocationService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  PlaceSuggestion? get cachedPlace => _cachedPlace;

  /// Loads saved place preference from local secure storage
  Future<PlaceSuggestion?> loadSavedLocation() async {
    try {
      final jsonStr = await _secureStorage.read(key: _storageKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      _cachedPlace = PlaceSuggestion.fromJson(map);
      return _cachedPlace;
    } catch (_) {
      return null;
    }
  }

  /// Saves the user's preferred location to local secure storage
  Future<void> saveLocation(PlaceSuggestion place) async {
    _cachedPlace = place;
    try {
      final map = {
        'name': place.name,
        'formatted': place.formatted,
        'district': place.district,
        'lat': place.lat,
        'lon': place.lon,
        'confidence': place.confidence,
      };
      await _secureStorage.write(key: _storageKey, value: jsonEncode(map));
    } catch (_) {}
  }

  /// Clears saved location preference
  Future<void> clearLocation() async {
    _cachedPlace = null;
    try {
      await _secureStorage.delete(key: _storageKey);
    } catch (_) {}
  }
}
