import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import 'app_update_service.dart';

class UpdateAvailableDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;

  const UpdateAvailableDialog({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, AppUpdateInfo updateInfo) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.isForceUpdate,
      builder: (context) => UpdateAvailableDialog(updateInfo: updateInfo),
    );
  }

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  bool _isDownloading = false;
  int _progress = 0;
  String? _statusText;
  StreamSubscription<OtaEvent>? _otaSubscription;

  @override
  void dispose() {
    _otaSubscription?.cancel();
    super.dispose();
  }

  void _startUpdate() {
    setState(() {
      _isDownloading = true;
      _statusText = 'Starting download...';
      _progress = 0;
    });

    try {
      _otaSubscription = AppUpdateService.startDownloadAndInstall(
        widget.updateInfo.apkDownloadUrl,
      ).listen(
        (OtaEvent event) {
          if (!mounted) return;
          setState(() {
            switch (event.status) {
              case OtaStatus.DOWNLOADING:
                _progress = int.tryParse(event.value ?? '0') ?? _progress;
                _statusText = 'Downloading update: $_progress%';
                break;
              case OtaStatus.INSTALLING:
              case OtaStatus.INSTALLATION_DONE:
                _progress = 100;
                _statusText = 'Opening Android installer...';
                break;
              case OtaStatus.ALREADY_RUNNING_ERROR:
                _statusText = 'Download already running.';
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                _isDownloading = false;
                _statusText = 'Installation permission denied.';
                break;
              case OtaStatus.INTERNAL_ERROR:
              case OtaStatus.DOWNLOAD_ERROR:
              case OtaStatus.CHECKSUM_ERROR:
                _isDownloading = false;
                _statusText = 'Download error. Please check internet connection.';
                break;
              default:
                break;
            }
          });
        },
        onError: (dynamic error) {
          if (!mounted) return;
          setState(() {
            _isDownloading = false;
            _statusText = 'Failed to download update.';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _statusText = 'Error launching installer: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassContainer(
        borderRadius: 28,
        blur: 24,
        padding: const EdgeInsets.all(24),
        color: Colors.white.withValues(alpha: 0.95),
        border: Border.all(
          color: const Color(0xFF346EF6).withValues(alpha: 0.3),
          width: 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge Icon
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0053DB).withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Center(
              child: Text(
                'New Update Available!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Version Pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EAF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'v${widget.updateInfo.latestVersionName} (Build ${widget.updateInfo.latestBuildNumber})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0053DB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Release Notes Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's New:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.updateInfo.releaseNotes,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress Bar / Status
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _progress > 0 ? _progress / 100 : null,
                backgroundColor: const Color(0xFFE2EAF8),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0053DB)),
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _statusText ?? 'Downloading...',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0053DB),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ] else if (_statusText != null) ...[
              Center(
                child: Text(
                  _statusText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            if (!_isDownloading)
              Row(
                children: [
                  if (!widget.updateInfo.isForceUpdate) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0053DB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Update Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
