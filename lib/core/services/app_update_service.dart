import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:dio/dio.dart';

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
      latestBuildNumber: json['latest_build_number'] as int? ?? 1,
      latestVersionName: json['latest_version_name'] as String? ?? '1.0.0',
      apkDownloadUrl: json['apk_download_url'] as String? ?? '',
      releaseNotes: json['release_notes'] as String? ?? 'Bug fixes and performance improvements.',
      isForceUpdate: json['is_force_update'] as bool? ?? false,
    );
  }
}

class AppUpdateService {
  /// Default public raw JSON endpoint on GitHub
  static String versionCheckUrl =
      'https://raw.githubusercontent.com/Aryan8872/yellow-book/main/app_version.json';

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 6),
    receiveTimeout: const Duration(seconds: 6),
  ));

  /// Checks if a newer version is available compared to the currently installed app
  static Future<AppUpdateInfo?> checkForUpdate({String? customUrl}) async {
    try {
      final baseUrl = customUrl ?? versionCheckUrl;
      // Append timestamp query parameter to bypass GitHub Raw CDN caching
      final targetUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _dio.get(targetUrl);

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final updateInfo = AppUpdateInfo.fromJson(data);
        final packageInfo = await PackageInfo.fromPlatform();
        final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

        debugPrint('AppUpdateCheck: Installed Build=$currentBuildNumber, Server Build=${updateInfo.latestBuildNumber}');

        if (updateInfo.latestBuildNumber > currentBuildNumber &&
            updateInfo.apkDownloadUrl.isNotEmpty) {
          return updateInfo;
        }
      }
    } catch (e) {
      debugPrint('AppUpdateService: Check for update skipped or offline: $e');
    }
    return null;
  }

  /// Initiates OTA APK download and hands off to the Android OS package installer
  static Stream<OtaEvent> startDownloadAndInstall(String apkUrl) {
    try {
      return OtaUpdate().execute(
        apkUrl,
        destinationFilename: 'OfferNepal_Update.apk',
      );
    } catch (e) {
      debugPrint('AppUpdateService execute error: $e');
      rethrow;
    }
  }
}
