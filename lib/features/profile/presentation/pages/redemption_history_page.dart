import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_state.dart';

/// Buyer-visible redemption history (RED-01/RED-02).
/// Renders enriched rows straight from GET /redemptions/me — one request, no
/// client-side chaining (CONTEXT D1). StatusBadge extraction lands in 30-05;
/// an inline badge is used for now.
class RedemptionHistoryPage extends StatelessWidget {
  const RedemptionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RedemptionBloc>(
      create: (_) =>
          getIt<RedemptionBloc>()..add(const FetchMyRedemptionsRequested()),
      child: const _RedemptionHistoryView(),
    );
  }
}

class _RedemptionHistoryView extends StatelessWidget {
  const _RedemptionHistoryView();

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
          'Redemption History',
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.darkPill),
                strokeWidth: 2.5,
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
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 14),
                    Text(
                      'Failed to load history',
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
                      onPressed: () => context
                          .read<RedemptionBloc>()
                          .add(const FetchMyRedemptionsRequested()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkPill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RedemptionHistoryLoaded) {
            final redemptions = state.redemptions;

            if (redemptions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => Future.sync(() => context
                    .read<RedemptionBloc>()
                    .add(const FetchMyRedemptionsRequested())),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  children: const [
                    SizedBox(height: 120),
                    _EmptyHistory(),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => Future.sync(() => context
                  .read<RedemptionBloc>()
                  .add(const FetchMyRedemptionsRequested())),
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                itemCount: redemptions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) =>
                    _HistoryRow(redemption: redemptions[index]),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Inline badge keyed to the canonical backend status union (E2):
/// INIT | PENDING_SYNC | REDEEMED | REJECTED | EXPIRED — "Cancelled" is UI
/// copy for REJECTED. Shared StatusBadge widget lands in plan 30-05.
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  ({Color bg, Color fg, String label}) get _mapping {
    switch (status.toUpperCase()) {
      case 'REDEEMED':
        return (
          bg: const Color(0xFF10B981).withValues(alpha: 0.15),
          fg: const Color(0xFF10B981),
          label: 'REDEEMED',
        );
      case 'EXPIRED':
        return (
          bg: const Color(0xFFEF4444).withValues(alpha: 0.12),
          fg: const Color(0xFFEF4444),
          label: 'EXPIRED',
        );
      case 'REJECTED':
        return (
          bg: const Color(0xFF6B7280).withValues(alpha: 0.12),
          fg: const Color(0xFF6B7280),
          label: 'CANCELLED',
        );
      case 'PENDING_SYNC':
        return (
          bg: AppTheme.pastelMint,
          fg: AppTheme.darkAnchor,
          label: 'PENDING',
        );
      default: // INIT (and any unknown status falls back to active)
        return (
          bg: AppTheme.pastelMint,
          fg: AppTheme.darkAnchor,
          label: 'ACTIVE',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _mapping;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: m.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        m.label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: m.fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final RedemptionEntity redemption;
  const _HistoryRow({required this.redemption});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatNpr(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    final text = value.toDouble().toStringAsFixed(2);
    return text.endsWith('00') ? text.substring(0, text.length - 3) : text;
  }

  @override
  Widget build(BuildContext context) {
    final r = redemption;
    final merchant = r.merchantName ?? r.merchant?.name ?? 'Merchant Partner';
    final branchName = r.branch?.name;
    final district = r.branch?.district;
    final locationLine = branchName != null
        ? (district != null && district.isNotEmpty ? '$branchName · $district' : branchName)
        : 'No branch selected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  merchant,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: r.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.offerTitle.isNotEmpty ? r.offerTitle : 'Special Offer',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  locationLine,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: branchName != null
                        ? AppTheme.textSecondary
                        : AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 5),
              Text(
                _formatDate(r.redeemedAt),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (r.savingsNpr != null) ...[
                const SizedBox(width: 10),
                Text(
                  'Saved NPR ${_formatNpr(r.savingsNpr!)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.savingsGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.confirmation_num_outlined,
                size: 36, color: Color(0xFF667EEA)),
          ),
          const SizedBox(height: 16),
          Text('No redemptions yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 6),
          Text('Every voucher you claim will show up here',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
