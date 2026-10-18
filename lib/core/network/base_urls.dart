import 'package:flutter/foundation.dart';

class BaseUrls {
  BaseUrls._();

  // Android Emulator standard loopback to host
  static const String androidEmulator = 'http://10.0.2.2:3000/api/v1';

  // iOS Simulator / Desktop / Web loopback
  static const String localHost = 'http://localhost:3000/api/v1';

  // Production backend hosted on Railway
  static const String production = 'https://yellow-bookapi-production.up.railway.app/api/v1';

  // Dynamic selector based on runtime target and debug status
  static String get current {
    const envUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kReleaseMode) {
      return production;
    }

    if (kIsWeb) {
      return localHost;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulator;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return localHost;
    }
  }
}
