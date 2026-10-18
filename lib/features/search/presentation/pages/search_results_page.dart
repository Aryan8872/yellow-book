import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;
  final String? initialCategory;

  const SearchResultsPage({
    super.key,
    required this.query,
    this.initialCategory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OffersBloc>()
        ..add(FetchOffersRequested(
          q: query.isNotEmpty ? query : null,
          category: initialCategory,
          page: 1,
          limit: 20,
          refresh: true,
        )),
      child: _SearchResultsView(query: query, initialCategory: initialCategory),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  final String query;
  final String? initialCategory;

  const _SearchResultsView({required this.query, this.initialCategory});

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  final List<String> _categories = [
    'All',
    'Dining',
    'Wellness',
    'Hotels',
    'Activities',
    'Retail',
    'Entertainment',
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _selectedCategory = widget.initialCategory ?? 'All';
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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

  void _triggerSearch(String q, {String? category}) {
    final selectedCat = category ?? _selectedCategory;
    final cat = selectedCat == 'All' ? null : selectedCat;
    context.read<OffersBloc>().add(FetchOffersRequested(
          q: q.trim().isEmpty ? null : q.trim(),
          category: cat,
          page: 1,
          limit: 20,
          refresh: true,
        ));
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppTheme.softCardShadow,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AppTheme.textPrimary, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (v) => _triggerSearch(v),
                              textInputAction: TextInputAction.search,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Search restaurants, stores, offers...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.textMuted, fontSize: 13),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: AppTheme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                _triggerSearch('');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.darkAnchor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkAnchor.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.map_outlined,
                          color: Colors.white, size: 22),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MapDiscoveryPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Category filter chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _triggerSearch(_searchController.text, category: cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.darkAnchor
                            : AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isSelected ? [] : AppTheme.softCardShadow,
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: BlocBuilder<OffersBloc, OffersState>(
                builder: (context, state) {
                  if (state is OffersLoading) return _buildSkeletonList();
                  if (state is OffersError) return _buildError(state.message);
                  if (state is OffersLoaded) {
                    if (state.offers.isEmpty) return _buildEmpty();
                    return _buildList(state);
                  }
                  return _buildSkeletonList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: 6,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 14),
          Text('No offers found',
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Try a different search or category',
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text('Could not load results',
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _triggerSearch(_searchController.text),
            child: Text('Retry',
                style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.accentPeriwinkleDark,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(OffersLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: state.offers.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.offers.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final offer = state.offers[index];
        return _OfferResultCard(
          offer: offer,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OfferDetailPage(offer: offer)),
          ),
        );
      },
    );
  }
}

class _OfferResultCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onTap;
  const _OfferResultCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discountText = offer.discountPercentage != null
        ? '${offer.discountPercentage}% OFF'
        : offer.estimatedSavingsNpr > 0
            ? 'Save NPR ${offer.estimatedSavingsNpr}'
            : 'Special Offer';

    final categoryLabel = _titleCase(offer.category.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                    ? Image.network(offer.imageUrl!,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _iconBox(offer.category.name))
                    : _iconBox(offer.category.name),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.merchantName ?? offer.title,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offer.title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppTheme.accentAmberDark),
                        const SizedBox(width: 3),
                        Text(offer.rating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        const SizedBox(width: 10),
                        Text(categoryLabel,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.pastelMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(discountText,
                    style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.darkAnchor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(String cat) {
    IconData icon;
    final lower = cat.toLowerCase();
    if (lower.contains('dining') || lower.contains('food')) {
      icon = Icons.restaurant_rounded;
    } else if (lower.contains('hotel') || lower.contains('travel')) {
      icon = Icons.hotel_rounded;
    } else if (lower.contains('wellness') || lower.contains('spa')) {
      icon = Icons.spa_rounded;
    } else {
      icon = Icons.local_offer_rounded;
    }
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.pastelPeriwinkle.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppTheme.darkAnchor, size: 26),
    );
  }

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 86,
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12,
                      width: 140,
                      color: AppTheme.borderLight,
                      margin: const EdgeInsets.only(bottom: 8)),
                  Container(height: 10, width: 100, color: AppTheme.borderLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
