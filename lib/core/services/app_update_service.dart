import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final int latestBuildNumber;
  final String latestVersionName;
  final String apkDownloadUrl;
  final String releaseNotes;
  final bool isForceUpdate;

  const AppUpdateInfo({
    required this.latestBuildNumber,
    required this.latestVersionName,
    required this.apkDownloadUrl,
    required this.releaseNotes,
    this.isForceUpdate = false,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestBuildNumber: _asInt(json['latest_build_number']) ?? 0,
      latestVersionName: json['latest_version_name']?.toString().trim() ?? '',
      apkDownloadUrl: json['apk_download_url']?.toString().trim() ?? '',
      releaseNotes:
          json['release_notes']?.toString().trim().isNotEmpty == true
              ? json['release_notes'].toString().trim()
              : 'Bug fixes and performance improvements.',
      isForceUpdate: json['is_force_update'] == true,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}

class AppUpdateService {
  AppUpdateService._();

  /// Authoritative manifest published atomically with every GitHub release.
  static const String releaseManifestUrl =
      'https://github.com/Aryan8872/yellow-book/releases/latest/download/app_version.json';

  /// Legacy fallback kept for older releases that only committed the manifest.
  static const String legacyManifestUrl =
      'https://raw.githubusercontent.com/Aryan8872/yellow-book/master/app_version.json';

  static String versionCheckUrl = releaseManifestUrl;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    ),
  );

  /// Returns null when the installed build is current, the platform cannot
  /// install APKs, or the manifest is unreachable. Never throws into the UI.
  static Future<AppUpdateInfo?> checkForUpdate({String? customUrl}) async {
    // OTA APK installation only exists on Android. Showing this dialog on web,
    // iOS or desktop would be misleading and can never be actioned.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    final urls = <String>[
      if (customUrl != null && customUrl.trim().isNotEmpty) customUrl.trim(),
      if (customUrl == null || customUrl.trim().isEmpty) versionCheckUrl,
      if (customUrl == null || customUrl.trim().isEmpty) legacyManifestUrl,
    ];

    for (final url in urls.toSet()) {
      final updateInfo = await _fetchManifest(url);
      if (updateInfo == null) continue;

      final packageInfo = await PackageInfo.fromPlatform();
      if (_isNewer(updateInfo, packageInfo)) {
        debugPrint(
          'AppUpdateCheck: installed=${packageInfo.version}+${packageInfo.buildNumber}, '
          'latest=${updateInfo.latestVersionName}+${updateInfo.latestBuildNumber}',
        );
        return updateInfo;
      }

      debugPrint(
        'AppUpdateCheck: already current at '
        '${packageInfo.version}+${packageInfo.buildNumber}',
      );
      return null;
    }

    return null;
  }

  static Future<AppUpdateInfo?> _fetchManifest(String url) async {
    try {
      // Cache-busting keeps GitHub's CDN from serving a stale manifest right
      // after a release.
      final separator = url.contains('?') ? '&' : '?';
      final response = await _dio.get(
        '$url${separator}t=${DateTime.now().millisecondsSinceEpoch}',
      );

      if (response.statusCode != 200 || response.data == null) return null;

      final dynamic raw = response.data;
      final dynamic decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) return null;

      final info = AppUpdateInfo.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      if (info.apkDownloadUrl.isEmpty) return null;
      return info;
    } catch (error) {
      debugPrint('AppUpdateService: manifest fetch failed ($url): $error');
      return null;
    }
  }

  /// A release is newer when its Android build number is higher. Version name
  /// is used only as a tie-breaker so semver-only releases still surface.
  static bool _isNewer(AppUpdateInfo info, PackageInfo current) {
    final currentBuild = int.tryParse(
          current.buildNumber.split('.').first.trim(),
        ) ??
        0;

    if (info.latestBuildNumber > currentBuild) return true;
    if (info.latestBuildNumber < currentBuild) return false;

    return _compareVersionNames(info.latestVersionName, current.version) > 0;
  }

  static int _compareVersionNames(String a, String b) {
    final aParts = _versionParts(a);
    final bParts = _versionParts(b);
    final length = aParts.length > bParts.length
        ? aParts.length
        : bParts.length;

    for (var i = 0; i < length; i++) {
      final left = i < aParts.length ? aParts[i] : 0;
      final right = i < bParts.length ? bParts[i] : 0;
      if (left != right) return left.compareTo(right);
    }
    return 0;
  }

  static List<int> _versionParts(String value) {
    return value
        .split('.')
        .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList(growable: false);
  }

  /// Human-readable installed version, e.g. `v1.0.14+14`.
  static Future<String> installedVersionLabel() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return 'v${info.version}+${info.buildNumber}';
    } catch (_) {
      return 'unknown';
    }
  }

  /// Initiates OTA APK download and hands off to the Android OS package
  /// installer.
  static Stream<OtaEvent> startDownloadAndInstall(String apkUrl) {
    try {
      return OtaUpdate().execute(
        apkUrl,
        destinationFilename: 'OfferNepal_Update.apk',
      );
    } catch (error) {
      debugPrint('AppUpdateService execute error: $error');
      rethrow;
    }
  }
}
