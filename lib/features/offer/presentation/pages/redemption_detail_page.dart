import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/status_badge.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_state.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/offer/presentation/pages/merchant_detail_page.dart';

class RedemptionDetailPage extends StatefulWidget {
  final RedemptionEntity redemption;
  final RedemptionBloc? redemptionBloc;

  const RedemptionDetailPage({
    super.key,
    required this.redemption,
    this.redemptionBloc,
  });

  @override
  State<RedemptionDetailPage> createState() => _RedemptionDetailPageState();
}

class _RedemptionDetailPageState extends State<RedemptionDetailPage> {
  late final RedemptionBloc _redemptionBloc;
  late final bool _ownsRedemptionBloc;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _hasResynced = false;
  bool _isCancelling = false;
  String? _cancellationError;
  late String _currentStatus;
  bool _termsExpanded = false;
  bool _codeCopied = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.redemption.status;
    _ownsRedemptionBloc = widget.redemptionBloc == null;
    _redemptionBloc = widget.redemptionBloc ?? getIt<RedemptionBloc>();
    _calculateRemainingTime();
    if (_isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _calculateRemainingTime();
            // Server re-sync when timer hits 0
            if (_remainingSeconds == 0 && !_hasResynced) {
              _hasResynced = true;
              _resyncRedemption();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_ownsRedemptionBloc) {
      unawaited(_redemptionBloc.close());
    }
    super.dispose();
  }

  void _calculateRemainingTime() {
    if (widget.redemption.expiresAt != null) {
      final expiry = widget.redemption.expiresAt!;
      final now = DateTime.now();
      _remainingSeconds = expiry.difference(now).inSeconds;
      if (_remainingSeconds < 0) _remainingSeconds = 0;
    }
  }

  void _resyncRedemption() {
    // Trigger a refetch to check if redemption has expired on server
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '00:00';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getCountdownColor() {
    if (_remainingSeconds <= 60) return const Color(0xFFEF4444);
    if (_remainingSeconds <= 600) return const Color(0xFFE5A93C);
    return AppTheme.emeraldJade;
  }

  void _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancel this redemption?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Yes, cancel it'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _cancelRedemption();
    }
  }

  void _cancelRedemption() {
    _redemptionBloc.add(CancelRedemptionRequested(widget.redemption.id));
  }

  void _showOnMap() {
    final branch = widget.redemption.branch;
    if (branch != null && branch.lat != null && branch.lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapDiscoveryPage(
            initialBranch: (
              lat: branch.lat!,
              lng: branch.lng!,
              title: branch.name,
            ),
          ),
        ),
      );
    }
  }

  void _navigateToMerchant() {
    final merchant = widget.redemption.merchant;
    if (merchant != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MerchantDetailPage(
            merchantId: merchant.id,
            merchantName: merchant.name,
            logoUrl: merchant.logoUrl,
            branches: merchant.branches,
          ),
        ),
      );
    }
  }

  void _copyVoucherCode() {
    final code = widget.redemption.redemptionCode;
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      setState(() => _codeCopied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _codeCopied = false);
      });
    }
  }

  void _openDirections() {
    final branch = widget.redemption.branch;
    if (branch != null && branch.lat != null && branch.lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapDiscoveryPage(
            initialBranch: (
              lat: branch.lat!,
              lng: branch.lng!,
              title: branch.name,
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MapDiscoveryPage(),
        ),
      );
    }
  }

  void _callBranch() {
    final phone = widget.redemption.branch?.phone;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available for this branch'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textSecondary,
        ),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone.trim());
    launchUrl(uri).catchError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open dialer for $phone'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.textSecondary,
          ),
        );
      }
      return false;
    });
  }

  bool get _isExpired => _remainingSeconds <= 0;
  bool get _isActive =>
      _currentStatus == 'INIT' || _currentStatus == 'PENDING_SYNC';

  @override
  Widget build(BuildContext context) {
    final redemption = widget.redemption;
    final offer = redemption.offer;
    final merchant = redemption.merchant;
    final branch = redemption.branch;

    return BlocProvider.value(
      value: _redemptionBloc,
      child: BlocListener<RedemptionBloc, RedemptionState>(
        listener: (context, state) {
          if (state is RedemptionCancelSuccess) {
            setState(() {
              _isCancelling = false;
              _currentStatus = state.status;
              _cancellationError = null;
            });
            _timer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Redemption cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is RedemptionLoading && _isActive) {
            setState(() {
              _isCancelling = true;
              _cancellationError = null;
            });
          } else if (state is RedemptionError) {
            setState(() {
              _isCancelling = false;
              _cancellationError = state.message;
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.canvasBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 2,
            surfaceTintColor: AppTheme.surfaceContainer,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppTheme.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Voucher QR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // ── Official OfferNepal Pass Badge ─────────────────────────
                _buildPassBadge(),
                const SizedBox(height: 12),

                // ── Hero Status Card ──────────────────────────────────────
                _buildHeroStatusCard(redemption, merchant, branch),
                const SizedBox(height: 12),

                // ── QR Code Card ──────────────────────────────────────────
                if (_isActive && !_isExpired) ...[
                  _buildQrCard(redemption),
                  const SizedBox(height: 12),
                ],

                // ── Expired State ─────────────────────────────────────────
                if (_isExpired && _isActive) ...[
                  _buildExpiredState(),
                  const SizedBox(height: 12),
                ],

                // ── Deal Summary Recap with Financial Pills ───────────────
                if (offer != null) ...[
                  _buildDealSummary(redemption, offer),
                  const SizedBox(height: 12),
                ],

                // ── Merchant Branch Card ──────────────────────────────────
                if (branch != null) ...[
                  _buildBranchCard(branch),
                  const SizedBox(height: 12),
                ],

                // ── Terms Accordion + Support Desk ────────────────────────
                _buildTermsAndSupport(offer),
                const SizedBox(height: 12),

                // ── Cancel Button (active only) ───────────────────────────
                if (_isActive) ...[
                  _buildCancelButton(),
                  const SizedBox(height: 8),
                ],
                if (_cancellationError != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _cancellationError!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION BUILDERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPassBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 16,
                color: AppTheme.emeraldJade,
              ),
              const SizedBox(width: 6),
              Text(
                'Official OfferNepal Pass',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStatusCard(
    RedemptionEntity redemption,
    RedemptionMerchantInfo? merchant,
    RedemptionBranchInfo? branch,
  ) {
    final merchantName = merchant?.name ?? 'Merchant';
    final branchAddress = branch != null
        ? '${branch.address ?? ''}, ${branch.district ?? ''}'
        : 'Nepal';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: merchant info + pulsing status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Merchant icon
              GestureDetector(
                onTap: _navigateToMerchant,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: merchant?.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            merchant!.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Center(
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 28,
                                color: AppTheme.crimsonPrimary,
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 28,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    Row(
                      children: [
                        Text(
                          redemption.offer?.categoryName?.toUpperCase() ?? 'OFFER',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppTheme.emeraldJade,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppTheme.emeraldJade,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      merchantName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      branchAddress,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Pulsing status badge
              _buildPulsingStatus(),
            ],
          ),

          const SizedBox(height: 12),

          // Voucher code row with copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    redemption.redemptionCode ?? '—',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                // Copy button
                GestureDetector(
                  onTap: _copyVoucherCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _codeCopied ? Icons.check : Icons.content_copy,
                          size: 14,
                          color: AppTheme.crimsonPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _codeCopied ? 'Copied!' : 'Copy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingStatus() {
    final isRedeemed = _currentStatus == 'REDEEMED';
    final isCancelled = _currentStatus == 'CANCELLED';
    final statusLabel = isRedeemed
        ? 'REDEEMED'
        : isCancelled
            ? 'CANCELLED'
            : _isExpired
                ? 'EXPIRED'
                : 'READY TO REDEEM';
    final statusColor = isRedeemed
        ? AppTheme.emeraldJade
        : isCancelled
            ? const Color(0xFFEF4444)
            : _isExpired
                ? const Color(0xFFEF4444)
                : AppTheme.emeraldJade;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot (only when active)
          if (_isActive && !_isExpired)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          Text(
            statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(RedemptionEntity redemption) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Security gradient bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  AppTheme.crimsonPrimary,
                  AppTheme.emeraldJade,
                  AppTheme.crimsonPrimary.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // QR code
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: redemption.computedQrPayload,
              version: QrVersions.auto,
              size: 220,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF131B2E),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF131B2E),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Present this QR code to the cashier or server at checkout',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Countdown chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.update, size: 16, color: AppTheme.emeraldJade),
                const SizedBox(width: 6),
                Text(
                  'Code active • Auto-refreshes in ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  _formatTime(_remainingSeconds),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _getCountdownColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        children: [
          StatusBadge(status: 'EXPIRED'),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.45,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: widget.redemption.computedQrPayload,
                version: QrVersions.auto,
                size: 150,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The merchant code is no longer valid.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealSummary(
    RedemptionEntity redemption,
    RedemptionOfferInfo offer,
  ) {
    final origPrice = (offer.originalPriceNpr ?? 0).toInt();
    final savingsNpr = (redemption.savingsNpr ?? offer.estimatedSavingsNpr ?? 0).toInt();
    final discountPct = (offer.discountPercentage ?? 0).toInt();

    // Compute totalValue: use origPrice when available, else back-calculate from
    // savings + discount %, else mark as unknown (0 means we won't show values).
    final int totalValue = origPrice > 0
        ? origPrice
        : (savingsNpr > 0 && discountPct > 0
            ? (savingsNpr * 100 ~/ discountPct)
            : 0);

    final int saved = savingsNpr > 0
        ? savingsNpr
        : (totalValue > 0 && discountPct > 0
            ? (totalValue * discountPct ~/ 100)
            : 0);

    final int paidAmount = totalValue > 0 && totalValue > saved
        ? (totalValue - saved)
        : 0;

    // Whether we have meaningful numbers to show
    final bool hasFinancialData = totalValue > 0 || saved > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirmed Booking label
          Text(
            'CONFIRMED BOOKING',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.emeraldJade,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            redemption.offerTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // 3-pill financial grid — only shown when actual pricing data exists
          if (hasFinancialData)
            Row(
              children: [
                // Total Value
                Expanded(
                  child: _MetricPill(
                    label: 'Total Value',
                    value: 'Rs. $totalValue',
                    bgColor: AppTheme.surfaceContainerLow,
                    textColor: AppTheme.textPrimary,
                    isStrikethrough: true,
                  ),
                ),
                const SizedBox(width: 8),
                // Paid Amount
                Expanded(
                  child: _MetricPill(
                    label: 'Paid Amount',
                    value: 'Rs. $paidAmount',
                    bgColor: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                    textColor: AppTheme.crimsonPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                // You Saved
                Expanded(
                  child: _MetricPill(
                    label: 'You Saved',
                    value: 'Rs. $saved',
                    bgColor: AppTheme.emeraldJade.withValues(alpha: 0.1),
                    textColor: AppTheme.emeraldJade,
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.emeraldJade.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.emeraldJade.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 18, color: AppTheme.emeraldJade),
                  const SizedBox(width: 8),
                  Text(
                    'Privilege Deal Applied',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.emeraldJade,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Dates
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Claimed On',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(redemption.redeemedAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 16,
                          color: const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Valid Until',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      redemption.expiresAt != null
                          ? _formatDate(redemption.expiresAt!)
                          : '—',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(RedemptionBranchInfo branch) {
    final hasLocation = branch.lat != null && branch.lng != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Merchant Branch',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              branch.name,
              if (branch.address != null) branch.address!,
              if (branch.district != null) branch.district!,
            ].join(', '),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Map trigger card
          if (hasLocation)
            GestureDetector(
              onTap: _showOnMap,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.map_rounded,
                        size: 48,
                        color: AppTheme.textMuted.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 16,
                              color: AppTheme.crimsonPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to view on map',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Call + Directions buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _callBranch,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.call,
                          size: 20,
                          color: AppTheme.crimsonPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Call Branch',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _openDirections,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.crimsonPrimary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.crimsonPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Directions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndSupport(RedemptionOfferInfo? offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terms header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offer & Support Policy',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _termsExpanded = !_termsExpanded),
                child: Row(
                  children: [
                    Text(
                      _termsExpanded ? 'Hide Terms' : 'View Terms',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.crimsonPrimary,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _termsExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        size: 16,
                        color: AppTheme.crimsonPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Expandable terms content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  _buildTermItem(
                    Icons.check,
                    AppTheme.emeraldJade,
                    offer?.description ?? 'Valid for dine-in and takeaway. Subject to availability.',
                  ),
                  const SizedBox(height: 8),
                  _buildTermItem(
                    Icons.check,
                    AppTheme.emeraldJade,
                    'Service charge and VAT are covered under this OfferNepal voucher.',
                  ),
                  const SizedBox(height: 8),
                  _buildTermItem(
                    Icons.info_outline,
                    AppTheme.textMuted,
                    'Cancellations permitted before expiry via OfferNepal.',
                  ),
                ],
              ),
            ),
            crossFadeState: _termsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.transparent, height: 1),

          // Support desk
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.emeraldJade.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.support_agent,
                    size: 20,
                    color: AppTheme.emeraldJade,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instant Support Desk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Viber • WhatsApp • Hotline',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    'Connect',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.crimsonPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(IconData icon, Color iconColor, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isCancelling ? null : _showCancelDialog,
        icon: _isCancelling
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cancel_rounded, size: 20),
        label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Redemption'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Financial Metric Pill
// ─────────────────────────────────────────────────────────────────────────────
class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color textColor;
  final bool isStrikethrough;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.textColor,
    this.isStrikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
              decoration:
                  isStrikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
