import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'package:entertainer/features/offer/presentation/bloc/favourites_bloc.dart';
import 'package:entertainer/features/search/presentation/widgets/rich_offer_card.dart';
import 'package:entertainer/features/search/presentation/widgets/offer_filter_bottom_sheet.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;
  final String? initialCategory;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? placeLabel;
  final OfferFilterCriteria? initialCriteria;

  const SearchResultsPage({
    super.key,
    required this.query,
    this.initialCategory,
    this.lat,
    this.lng,
    this.radiusKm,
    this.placeLabel,
    this.initialCriteria,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<OffersBloc>()
            ..add(FetchOffersRequested(
              q: query.isNotEmpty ? query : null,
              category: initialCriteria?.category ?? initialCategory,
              lat: lat,
              lng: lng,
              radiusKm: initialCriteria?.radiusKm ?? radiusKm,
              page: 1,
              limit: 20,
              refresh: true,
            )),
        ),
        BlocProvider(
          create: (_) => getIt<FavouritesBloc>()..add(const FavouritesLoadRequested()),
        ),
      ],
      child: _SearchResultsView(
        query: query,
        initialCategory: initialCategory,
        placeLabel: placeLabel,
        initialCriteria: initialCriteria,
      ),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  final String query;
  final String? initialCategory;
  final String? placeLabel;
  final OfferFilterCriteria? initialCriteria;

  const _SearchResultsView({
    required this.query,
    this.initialCategory,
    this.placeLabel,
    this.initialCriteria,
  });

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  late OfferFilterCriteria _currentCriteria;
  String _selectedSort = 'Recommended';

  final List<String> _sortOptions = [
    'Recommended',
    'Distance: Near to Far',
    'Discount: High to Low',
    'Price: Low to High',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _currentCriteria = widget.initialCriteria ??
        OfferFilterCriteria(
          category: widget.initialCategory,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<OffersBloc>();
      if (bloc.state is OffersLoaded) {
        final loaded = bloc.state as OffersLoaded;
        if (loaded.hasMore && !loaded.isLoadingMore) {
          bloc.add(const LoadMoreOffersRequested());
        }
      }
    }
  }

  void _triggerSearch({OfferFilterCriteria? criteria}) {
    final effective = criteria ?? _currentCriteria;
    context.read<OffersBloc>().add(
      FetchOffersRequested(
        q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        category: effective.category,
        radiusKm: effective.radiusKm,
        page: 1,
        limit: 20,
        refresh: true,
      ),
    );
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openFilterDialog() async {
    final updated = await OfferFilterBottomSheet.show(
      context,
      initialCriteria: _currentCriteria,
    );

    if (updated != null && mounted) {
      setState(() {
        _currentCriteria = updated;
      });
      _triggerSearch(criteria: updated);
    }
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Sort Offers By',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Divider(),
            ..._sortOptions.map((opt) {
              final isChosen = _selectedSort == opt;
              return ListTile(
                title: Text(
                  opt,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isChosen ? FontWeight.w800 : FontWeight.w600,
                    color: isChosen ? AppTheme.crimsonPrimary : AppTheme.textPrimary,
                  ),
                ),
                trailing: isChosen
                    ? const Icon(Icons.check_rounded, color: AppTheme.crimsonPrimary)
                    : null,
                onTap: () {
                  setState(() => _selectedSort = opt);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Sub-Header matching search_result_page_ui.html ─────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              decoration: BoxDecoration(
                color: AppTheme.canvasBg.withValues(alpha: 0.95),
                border: const Border(
                  bottom: BorderSide(color: AppTheme.borderLight, width: 0.8),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      // Search pill input
                      Expanded(
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, size: 20, color: AppTheme.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onSubmitted: (_) => _triggerSearch(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search momo, spa, dining...',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: AppTheme.textMuted,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _triggerSearch();
                                  },
                                  child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter Trigger Button with Badge Counter
                      GestureDetector(
                        onTap: _openFilterDialog,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: _currentCriteria.activeCount > 0
                                ? AppTheme.surfaceDark
                                : AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: _currentCriteria.activeCount > 0
                                    ? Colors.white
                                    : AppTheme.crimsonPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Filters',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _currentCriteria.activeCount > 0
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              if (_currentCriteria.activeCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.crimsonPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${_currentCriteria.activeCount}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Active Filter Badges Rail ──────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        if (_currentCriteria.radiusKm != null)
                          _buildRemovableFilterBadge(
                            icon: Icons.near_me_rounded,
                            label: 'Within ${_currentCriteria.radiusKm!.toInt()} km',
                            onRemove: () {
                              setState(() {
                                _currentCriteria = _currentCriteria.copyWith(clearRadius: true);
                              });
                              _triggerSearch();
                            },
                          ),
                        if (_currentCriteria.minRating != null)
                          _buildRemovableFilterBadge(
                            icon: Icons.star_rounded,
                            label: '${_currentCriteria.minRating}+ Stars',
                            onRemove: () {
                              setState(() {
                                _currentCriteria = _currentCriteria.copyWith(clearRating: true);
                              });
                              _triggerSearch();
                            },
                          ),
                        if (_currentCriteria.minDiscountPercent != null)
                          _buildRemovableFilterBadge(
                            icon: Icons.percent_rounded,
                            label: '${_currentCriteria.minDiscountPercent}%+ OFF',
                            onRemove: () {
                              setState(() {
                                _currentCriteria = _currentCriteria.copyWith(clearDiscount: true);
                              });
                              _triggerSearch();
                            },
                          ),
                        if (_currentCriteria.category != null)
                          _buildRemovableFilterBadge(
                            icon: Icons.category_rounded,
                            label: _currentCriteria.category!,
                            onRemove: () {
                              setState(() {
                                _currentCriteria = _currentCriteria.copyWith(clearCategory: true);
                              });
                              _triggerSearch();
                            },
                          ),
                        GestureDetector(
                          onTap: _openFilterDialog,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.add_rounded, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'More Filters',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
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
            ),

            // ── Meta Count & Sort Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: BlocBuilder<OffersBloc, OffersState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is OffersLoaded) {
                    count = state.total > 0 ? state.total : state.offers.length;
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$count offers',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.placeLabel != null
                                ? 'in ${widget.placeLabel}'
                                : 'in Kathmandu Valley',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      // Sort dropdown trigger
                      GestureDetector(
                        onTap: _showSortDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Sort: ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                _selectedSort,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.crimsonPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 16,
                                color: AppTheme.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Offers List ──────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<OffersBloc, OffersState>(
                builder: (context, state) {
                  if (state is OffersLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 4,
                      itemBuilder: (_, _) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkeletonLoader(
                          height: 280,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }

                  if (state is OffersError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.crimsonPrimary),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _triggerSearch(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.crimsonPrimary,
                            ),
                            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is OffersLoaded) {
                    var offers = state.offers;

                    // Apply client-side filters if needed
                    if (_currentCriteria.minRating != null) {
                      offers = offers.where((o) => o.rating >= _currentCriteria.minRating!).toList();
                    }
                    if (_currentCriteria.minDiscountPercent != null) {
                      offers = offers.where((o) => (o.discountPercentage ?? 0) >= _currentCriteria.minDiscountPercent!).toList();
                    }

                    // Apply Sort
                    if (_selectedSort == 'Discount: High to Low') {
                      offers = List.of(offers)..sort((a, b) => (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));
                    } else if (_selectedSort == 'Price: Low to High') {
                      offers = List.of(offers)..sort((a, b) => (a.discountedPriceNpr ?? 0).compareTo(b.discountedPriceNpr ?? 0));
                    }

                    if (offers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 54, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No matching deals found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try relaxing some filters or changing your query',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentCriteria = const OfferFilterCriteria();
                                  _searchController.clear();
                                });
                                _triggerSearch(criteria: const OfferFilterCriteria());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.crimsonPrimary,
                              ),
                              child: const Text('Reset All Filters', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: offers.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == offers.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.crimsonPrimary,
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RichOfferCard(offer: offers[index]),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableFilterBadge({
    required IconData icon,
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.cancel_rounded,
              size: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
