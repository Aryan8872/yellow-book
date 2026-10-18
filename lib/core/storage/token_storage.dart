import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence layer for JWT tokens.
/// Maintains an in-memory cache for high-frequency synchronous reads (e.g. onRequest interceptors),
/// backed asynchronously by FlutterSecureStorage for persistence across application restarts.
class TokenStorage {
  static const _accessKey = 'offer_nepal_access_token';
  static const _refreshKey = 'offer_nepal_refresh_token';

  final FlutterSecureStorage _secureStorage;

  String? _accessToken;
  String? _refreshToken;
  bool _isInitialized = false;

  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isInitialized => _isInitialized;

  /// Loads persisted tokens into memory on app startup
  Future<void> init() async {
    try {
      _accessToken = await _secureStorage.read(key: _accessKey);
      _refreshToken = await _secureStorage.read(key: _refreshKey);
    } catch (_) {
      // In case of platform keystore corruption, fallback gracefully
      _accessToken = null;
      _refreshToken = null;
    } finally {
      _isInitialized = true;
    }
  }

  /// Saves tokens to in-memory cache and persists them to secure storage
  void save(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;

    // Fire and forget asynchronous write to secure storage
    _secureStorage.write(key: _accessKey, value: access).catchError((_) {});
    _secureStorage.write(key: _refreshKey, value: refresh).catchError((_) {});
  }

  /// Clears in-memory tokens and removes them from secure storage
  void clear() {
    _accessToken = null;
    _refreshToken = null;

    _secureStorage.delete(key: _accessKey).catchError((_) {});
    _secureStorage.delete(key: _refreshKey).catchError((_) {});
  }

  bool hasAccess() => _accessToken != null && _accessToken!.isNotEmpty;
}