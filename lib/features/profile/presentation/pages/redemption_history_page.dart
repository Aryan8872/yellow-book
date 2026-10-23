import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/widgets/status_badge.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/redemption_state.dart';
import 'package:entertainer/features/offer/presentation/pages/redemption_detail_page.dart';

/// Buyer-visible redemption history (RED-01/RED-02).
/// Renders enriched rows straight from GET /redemptions/me — one request, no
/// client-side chaining (CONTEXT D1). Uses canonical StatusBadge.
class RedemptionHistoryPage extends StatefulWidget {
  const RedemptionHistoryPage({super.key});

  @override
  State<RedemptionHistoryPage> createState() => _RedemptionHistoryPageState();
}

class _RedemptionHistoryPageState extends State<RedemptionHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  List<RedemptionEntity> _filterRedemptions(List<RedemptionEntity> redemptions) {
    var filtered = redemptions;

    // Status filter
    if (_selectedStatus != 'All') {
      filtered = filtered.where((r) {
        final status = r.status.toUpperCase();
        switch (_selectedStatus) {
          case 'Active':
            return status == 'INIT' || status == 'PENDING_SYNC';
          case 'Redeemed':
            return status == 'REDEEMED';
          case 'Expired':
            return status == 'EXPIRED';
          case 'Cancelled':
            return status == 'REJECTED';
          default:
            return true;
        }
      }).toList();
    }

    // Search filter (case-insensitive contains over offerTitle + merchantName)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        final offerTitle = r.offerTitle.toLowerCase();
        final merchantName = (r.merchantName ?? r.merchant?.name ?? '').toLowerCase();
        return offerTitle.contains(q) || merchantName.contains(q);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RedemptionBloc>(
      create: (_) =>
          getIt<RedemptionBloc>()..add(const FetchMyRedemptionsRequested()),
      child: Scaffold(
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
              return const _HistoryLoading();
            }

            if (state is RedemptionError) {
              return _HistoryError(
                message: state.message,
                onRetry: () => context
                    .read<RedemptionBloc>()
                    .add(const FetchMyRedemptionsRequested()),
              );
            }

            if (state is RedemptionHistoryLoaded) {
              final allRedemptions = state.redemptions;
              final filteredRedemptions = _filterRedemptions(allRedemptions);

              return RefreshIndicator(
                onRefresh: () => Future.sync(() => context
                    .read<RedemptionBloc>()
                    .add(const FetchMyRedemptionsRequested())),
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: _SearchBar(
                        controller: _searchController,
                        onClear: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                    // Status chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StatusChipRow(
                        selectedStatus: _selectedStatus,
                        onStatusChanged: (status) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Count chip
                    if (filteredRedemptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _CountChip(count: filteredRedemptions.length),
                        ),
                      ),
                    // List or empty state
                    Expanded(
                      child: filteredRedemptions.isEmpty
                          ? _HistoryEmpty(
                              isFiltered: _searchQuery.isNotEmpty || _selectedStatus != 'All',
                              query: _searchQuery,
                              status: _selectedStatus,
                              onClear: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedStatus = 'All';
                                });
                              },
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: filteredRedemptions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => _HistoryRow(
                                redemption: filteredRedemptions[index],
                              ),
                            ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by offer name',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textMuted),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _StatusChipRow extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;

  const _StatusChipRow({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final List<String> _statuses = const ['All', 'Active', 'Redeemed', 'Expired', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statuses.map((status) {
          final isSelected = selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (_) => onStatusChanged(status),
              selectedColor: AppTheme.darkPill,
              backgroundColor: AppTheme.cardSurface,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? AppTheme.darkPill : AppTheme.borderLight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;

  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Text(
        '$count total',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: const [
        SkeletonLoader(height: 100),
        SizedBox(height: 12),
        SkeletonLoader(height: 100),
        SizedBox(height: 12),
        SkeletonLoader(height: 100),
        SizedBox(height: 12),
        SkeletonLoader(height: 100),
      ],
    );
  }
}

class _HistoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              'Couldn\'t load your redemptions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.darkPill,
              ),
              child: const Text('Retry loading'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  final bool isFiltered;
  final String query;
  final String status;
  final VoidCallback onClear;

  const _HistoryEmpty({
    required this.isFiltered,
    required this.query,
    required this.status,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFiltered) {
      // No data at all
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_num_outlined,
                  color: Color(0xFF667EEA),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No redemptions yet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start redeeming offers to see your history here',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filtered empty
    String title;
    String subtitle;
    if (query.isNotEmpty) {
      title = 'No matches for "$query"';
      subtitle = 'Try a different search, or clear your status filter.';
    } else {
      title = 'No $status redemptions';
      subtitle = 'Try a different search, or clear your status filter.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppTheme.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.darkPill,
              ),
              child: const Text('Clear filters'),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final r = redemption;
    final merchant = r.merchantName ?? r.merchant?.name ?? 'Merchant Partner';
    final branchName = r.branch?.name;
    final district = r.branch?.district;
    final locationLine = branchName != null
        ? (district != null && district.isNotEmpty ? '$branchName · $district' : branchName)
        : 'No branch selected';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RedemptionDetailPage(redemption: r),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.confirmation_num_outlined,
                color: Color(0xFF667EEA),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.offerTitle.isNotEmpty ? r.offerTitle : 'Special Offer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    merchant,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locationLine,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status and date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: r.status),
                const SizedBox(height: 6),
                Text(
                  _formatDate(r.redeemedAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
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
