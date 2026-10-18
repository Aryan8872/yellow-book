import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_state.dart';
import 'package:entertainer/features/offer/presentation/widgets/redemption_code_sheet.dart';

class MyVouchersPage extends StatelessWidget {
  const MyVouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RedemptionBloc>(
      create: (_) => getIt<RedemptionBloc>()..add(const FetchMyRedemptionsRequested()),
      child: const _MyVouchersView(),
    );
  }
}

class _MyVouchersView extends StatelessWidget {
  const _MyVouchersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Vouchers & Redemptions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<RedemptionBloc, RedemptionState>(
        builder: (context, state) {
          if (state is RedemptionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPeriwinkle),
              ),
            );
          }

          if (state is RedemptionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 14),
                    Text(
                      'Failed to load vouchers',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RedemptionBloc>().add(const FetchMyRedemptionsRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkPill,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RedemptionHistoryLoaded) {
            final vouchers = state.redemptions;
            if (vouchers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 48,
                          color: AppTheme.accentPeriwinkle,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No vouchers yet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'When you redeem offers at participating merchants, your active QR passes and vouchers will appear here.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RedemptionBloc>().add(const FetchMyRedemptionsRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                itemCount: vouchers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = vouchers[index];
                  return _VoucherCard(
                    redemption: item,
                    onTap: () {
                      RedemptionCodeSheet.show(
                        context,
                        redemption: item,
                        onDone: () {
                          context.read<RedemptionBloc>().add(const FetchMyRedemptionsRequested());
                        },
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final RedemptionEntity redemption;
  final VoidCallback onTap;

  const _VoucherCard({
    required this.redemption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = redemption.status == 'INIT' || redemption.status == 'PENDING';
    final isCompleted = redemption.status == 'COMPLETED';
    final isExpired = redemption.status == 'EXPIRED' ||
        (redemption.expiresAt != null && redemption.expiresAt!.isBefore(DateTime.now()));

    Color badgeColor;
    Color badgeTextColor;
    String badgeText;

    if (isCompleted) {
      badgeColor = const Color(0xFF10B981).withValues(alpha: 0.15);
      badgeTextColor = const Color(0xFF10B981);
      badgeText = 'REDEEMED';
    } else if (isExpired) {
      badgeColor = const Color(0xFFEF4444).withValues(alpha: 0.12);
      badgeTextColor = const Color(0xFFEF4444);
      badgeText = 'EXPIRED';
    } else {
      badgeColor = AppTheme.pastelMint;
      badgeTextColor = AppTheme.darkAnchor;
      badgeText = 'ACTIVE PASS';
    }

    final code = redemption.redemptionCode ??
        (redemption.id.isNotEmpty ? redemption.id.substring(0, 8).toUpperCase() : '');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        redemption.merchantName ?? 'Merchant Partner',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: badgeTextColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  redemption.offerTitle.isNotEmpty ? redemption.offerTitle : 'Special Offer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 18, color: AppTheme.accentPeriwinkle),
                        const SizedBox(width: 6),
                        Text(
                          code,
                          style: GoogleFonts.spaceMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          isPending ? 'Tap to view QR' : 'Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentPeriwinkle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.accentPeriwinkle),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
