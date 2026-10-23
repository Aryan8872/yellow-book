import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  const RedemptionDetailPage({super.key, required this.redemption});

  @override
  State<RedemptionDetailPage> createState() => _RedemptionDetailPageState();
}

class _RedemptionDetailPageState extends State<RedemptionDetailPage> {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _hasResynced = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    if (widget.redemption.status == 'INIT' || widget.redemption.status == 'PENDING_SYNC') {
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
    _timer.cancel();
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
    // This would typically call a bloc event to refresh the specific redemption
    // For now, we'll just mark as needing refresh
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
    if (_remainingSeconds <= 60) return const Color(0xFFEF4444); // errorRed
    if (_remainingSeconds <= 600) return const Color(0xFFE5A93C); // amber
    return AppTheme.textPrimary;
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
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textSecondary,
          ),
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
    context.read<RedemptionBloc>().add(
      CancelRedemptionRequested(widget.redemption.sessionId),
    );
  }

  void _showOnMap() {
    final branch = widget.redemption.branch;
    if (branch != null && branch.lat != null && branch.lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapDiscoveryPage(
            initialBranch: (lat: branch.lat!, lng: branch.lng!, title: branch.name),
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

  bool get _isExpired => _remainingSeconds <= 0;
  bool get _isActive => widget.redemption.status == 'INIT' || widget.redemption.status == 'PENDING_SYNC';

  @override
  Widget build(BuildContext context) {
    final redemption = widget.redemption;
    final offer = redemption.offer;
    final merchant = redemption.merchant;
    final branch = redemption.branch;

    return BlocProvider(
      create: (_) => getIt<RedemptionBloc>(),
      child: BlocListener<RedemptionBloc, RedemptionState>(
        listener: (context, state) {
          if (state is RedemptionCancelSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Redemption cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
            if (mounted) {
              Navigator.pop(context, true);
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.canvasBg,
          appBar: AppBar(
            backgroundColor: AppTheme.canvasBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Redemption Details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status hero + redemption code chip
                _buildStatusHero(redemption),
                const SizedBox(height: 20),

                // INIT-only claim block with QR and countdown
                if (_isActive && !_isExpired) ...[
                  _buildClaimBlock(redemption),
                  const SizedBox(height: 20),
                ],

                // Expired content state
                if (_isExpired) ...[
                  _buildExpiredState(),
                  const SizedBox(height: 20),
                ],

                // Offer details card
                if (offer != null) ...[
                  _buildOfferCard(offer),
                  const SizedBox(height: 20),
                ],

                // Merchant card
                if (merchant != null) ...[
                  _buildMerchantCard(merchant),
                  const SizedBox(height: 20),
                ],

                // Branch card
                if (branch != null) ...[
                  _buildBranchCard(branch),
                  const SizedBox(height: 20),
                ],

                // Show in Map button
                if (branch != null && branch.lat != null && branch.lng != null)
                  _buildShowOnMapButton(branch)
                else if (branch != null)
                  _buildBranchUnavailableText(),

                // Cancel button (INIT only)
                if (_isActive && !_isExpired) ...[
                  const SizedBox(height: 20),
                  _buildCancelButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHero(RedemptionEntity redemption) {
    return Row(
      children: [
        StatusBadge(status: redemption.status),
        const SizedBox(width: 12),
        if (redemption.redemptionCode != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              redemption.redemptionCode!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClaimBlock(RedemptionEntity redemption) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        children: [
          // QR code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: redemption.computedQrPayload,
              version: QrVersions.auto,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          // Time remaining
          Text(
            'Time Remaining',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(_remainingSeconds),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: _getCountdownColor(),
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
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
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

  Widget _buildOfferCard(RedemptionOfferInfo offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.coverImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                offer.coverImage!,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer_rounded, size: 40, color: AppTheme.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            widget.redemption.offerTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          if (offer.description != null) ...[
            const SizedBox(height: 8),
            Text(
              offer.description!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (offer.discountPercentage != null) ...[
                Text(
                  '${offer.discountPercentage}% OFF',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkPill,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (offer.estimatedSavingsNpr != null)
                Text(
                  'Save NPR ${offer.estimatedSavingsNpr}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.savingsGreen,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(RedemptionMerchantInfo merchant) {
    return InkWell(
      onTap: _navigateToMerchant,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Row(
          children: [
            // Logo circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: merchant.logoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        merchant.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            merchant.name.isNotEmpty ? merchant.name[0].toUpperCase() : '?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF667EEA),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        merchant.name.isNotEmpty ? merchant.name[0].toUpperCase() : '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF667EEA),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Name and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textMuted,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(RedemptionBranchInfo branch) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branch Location',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            branch.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          if (branch.address != null) ...[
            const SizedBox(height: 4),
            Text(
              branch.address!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (branch.district != null) ...[
            const SizedBox(height: 4),
            Text(
              branch.district!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowOnMapButton(RedemptionBranchInfo branch) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _showOnMap,
        icon: const Icon(Icons.map_rounded, size: 20),
        label: const Text('Show in Map'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.darkPill,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchUnavailableText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Branch location unavailable',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textMuted,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: _showCancelDialog,
        icon: const Icon(Icons.cancel_rounded, size: 20),
        label: const Text('Cancel Redemption'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
