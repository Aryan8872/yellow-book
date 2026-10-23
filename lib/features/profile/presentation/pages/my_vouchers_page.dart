import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_state.dart';
import 'package:entertainer/features/offer/presentation/pages/redemption_detail_page.dart';
import 'package:entertainer/features/home/presentation/pages/home_page.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';

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

class _MyVouchersView extends StatefulWidget {
  const _MyVouchersView();

  @override
  State<_MyVouchersView> createState() => _MyVouchersViewState();
}

class _MyVouchersViewState extends State<_MyVouchersView> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Active', 'Redeemed', 'Expired', 'Cancelled'];

  List<RedemptionEntity> _filterRedemptions(List<RedemptionEntity> redemptions) {
    if (_selectedFilter == 'All') return redemptions;

    return redemptions.where((r) {
      final status = r.status.toUpperCase();
      switch (_selectedFilter) {
        case 'Active':
          return status == 'INIT' || status == 'PENDING';
        case 'Redeemed':
          return status == 'REDEEMED' || status == 'COMPLETED';
        case 'Expired':
          return status == 'EXPIRED' ||
              (r.expiresAt != null && r.expiresAt!.isBefore(DateTime.now()));
        case 'Cancelled':
          return status == 'REJECTED' || status == 'CANCELLED';
        default:
          return true;
      }
    }).toList();
  }

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
            final filteredVouchers = _filterRedemptions(vouchers);

            // Filter pills
            final filterPills = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: AppTheme.accentPeriwinkle.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.accentPeriwinkle,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.accentPeriwinkle : AppTheme.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppTheme.accentPeriwinkle : AppTheme.borderSubtle,
                        ),
                      ),
                      backgroundColor: AppTheme.cardSurface,
                    );
                  },
                ),
              ),
            );

            if (filteredVouchers.isEmpty) {
              return Column(
                children: [
                  filterPills,
                  Expanded(
                    child: Center(
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
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage(
                                      user: User(
                                        id: '',
                                        email: '',
                                        name: '',
                                        role: 'CONSUMER',
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.darkPill,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Browse Offers', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                filterPills,
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<RedemptionBloc>().add(const FetchMyRedemptionsRequested());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemCount: filteredVouchers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = filteredVouchers[index];
                        return _VoucherCard(
                          redemption: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RedemptionDetailPage(
                                  redemption: item.toJson(),
                                ),
                              ),
                            );
                          },
                          onCancel: () {
                            context.read<RedemptionBloc>().add(CancelRedemptionRequested(item.id));
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
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
  final VoidCallback? onCancel;

  const _VoucherCard({
    required this.redemption,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = redemption.status == 'INIT' || redemption.status == 'PENDING';
    final isCompleted = redemption.status == 'REDEEMED' || redemption.status == 'COMPLETED';
    final isExpired = redemption.status == 'EXPIRED' ||
        (redemption.expiresAt != null && redemption.expiresAt!.isBefore(DateTime.now()));
    final isCancelled = redemption.status == 'REJECTED' || redemption.status == 'CANCELLED';

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
    } else if (isCancelled) {
      badgeColor = const Color(0xFF6B7280).withValues(alpha: 0.12);
      badgeTextColor = const Color(0xFF6B7280);
      badgeText = 'CANCELLED';
    } else {
      badgeColor = AppTheme.pastelMint;
      badgeTextColor = AppTheme.darkAnchor;
      badgeText = 'ACTIVE';
    }

    final code = redemption.redemptionCode ??
        (redemption.id.isNotEmpty ? redemption.id.substring(0, 8).toUpperCase() : '');

    // Calculate time remaining
    String timeText = '';
    if (isPending && redemption.expiresAt != null) {
      final remaining = redemption.expiresAt!.difference(DateTime.now());
      if (remaining.inSeconds > 0) {
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        timeText = '${minutes}m ${seconds}s remaining';
      } else {
        timeText = 'Expired';
      }
    } else if (isCompleted) {
      timeText = 'Redeemed';
    } else if (isExpired) {
      timeText = 'Expired';
    } else if (isCancelled) {
      timeText = 'Cancelled';
    }

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
                        Icon(
                          isPending ? Icons.access_time_rounded : Icons.info_outline_rounded,
                          size: 14,
                          color: isPending && redemption.expiresAt != null && redemption.expiresAt!.isAfter(DateTime.now())
                              ? AppTheme.savingsGreen
                              : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isPending && redemption.expiresAt != null && redemption.expiresAt!.isAfter(DateTime.now())
                                ? AppTheme.savingsGreen
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isPending && onCancel != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel Redemption'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
