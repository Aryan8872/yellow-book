import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/presentation/pages/reward_history_page.dart';

/// Clean, flat Reward Detail Page.
/// Implements the exact perforated voucher look, security QR code, offline 6-digit PIN,
/// and merchant context from mobile_app_ui_html/reward_detai_page_ui.html without any AI gradients.
class ClaimedRewardDetailPage extends StatelessWidget {
  final RewardHistoryItem reward;

  const ClaimedRewardDetailPage({
    super.key,
    required this.reward,
  });

  void _copyPin(BuildContext context) {
    Clipboard.setData(ClipboardData(text: reward.pin));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offline PIN ${reward.pin} copied!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = reward.status == 'active';

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reward Detail',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.textMuted),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Check out my OfferNepal reward: ${reward.title}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reward details copied to share!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Header Status & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.emeraldJade.withValues(alpha: 0.12)
                      : AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.emeraldJade : AppTheme.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isActive ? 'ACTIVE REWARD' : 'REDEEMED',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isActive ? AppTheme.emeraldJade : AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    reward.expiryText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            reward.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 16, color: AppTheme.crimsonPrimary),
              const SizedBox(width: 4),
              Text(
                reward.merchantName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                ' • ${reward.branchLocation}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Perforated Ticket Card
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Upper Section: QR Code & Live Dynamic Token
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.emeraldJade,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Security QR refreshes automatically',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // QR Code Container (High-contrast clean)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: QrImageView(
                          data: 'OFFERNEPAL-SECURE-TOKEN:${reward.code}:${reward.pin}',
                          version: QrVersions.auto,
                          size: 160.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0F172A),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Present this QR or fallback PIN to the cashier upon billing.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Perforated Divider
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppTheme.canvasBg,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const dashWidth = 5.0;
                          const dashSpace = 4.0;
                          final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(dashCount, (_) {
                              return const SizedBox(
                                width: dashWidth,
                                height: 1.5,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppTheme.canvasBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),

                // Lower Section: Offline Fallback PIN & Voucher Code
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OFFLINE FALLBACK PIN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  reward.pin.split('').join(' '),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.surfaceDark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _copyPin(context),
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: Text(
                                'COPY PIN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Voucher ID',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            reward.code,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Merchant Location & Assistance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merchant Guidelines & Help',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Valid for dine-in and takeaway at the specified branch.'),
                _buildBulletPoint('Cannot be combined with other ongoing in-house promotions.'),
                _buildBulletPoint('For assistance, contact OfferNepal support or front desk staff.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5, right: 8),
            child: Icon(Icons.circle, size: 5, color: AppTheme.textMuted),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

