import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/services/notification_inbox_service.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_bloc.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_event.dart';
import 'package:entertainer/features/offer/presentation/bloc/offers_state.dart';
import 'package:entertainer/features/offer/presentation/pages/offer_detail_page.dart';
import 'package:entertainer/features/offer/presentation/pages/category_offers_page.dart';
import 'package:entertainer/features/profile/presentation/pages/profile_page.dart';
import 'package:entertainer/features/home/presentation/pages/notifications_page.dart';
import 'package:entertainer/core/services/user_location_service.dart';
import 'package:entertainer/features/home/presentation/widgets/location_selection_modal.dart';
import 'package:entertainer/features/search/presentation/pages/search_results_page.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_state.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/core/layout/main_shell_screen.dart';

import 'package:entertainer/features/home/data/datasources/category_remote_datasource.dart';
import 'package:entertainer/features/offer/data/datasource/branch_remote_datasource.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';
import 'package:entertainer/features/offer/presentation/pages/merchant_detail_page.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
        ),
        BlocProvider(
          create: (_) => getIt<OffersBloc>()
            ..add(
              const FetchOffersRequested(page: 1, limit: 30, radiusKm: 50, refresh: true),
            ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthInitial) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              }
            },
          ),
          BlocListener<HomeBloc, HomeState>(
            listener: (context, homeState) {
              if (homeState is NavigateToOfferDetail) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfferDetailPage(offer: homeState.offer),
                  ),
                );
              } else if (homeState is NavigateToCategoryOffers) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryOffersPage(
                      categoryName: homeState.categoryName,
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: _HomeView(user: user),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  final User user;

  const _HomeView({required this.user});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final NotificationInboxService _inboxService = NotificationInboxService();

  String _currentLocation = 'Kathmandu Valley';
  PlaceSuggestion? _selectedPlace;
  int _unreadCount = 0;
  String _activeQuickChip = 'Near me';

  List<CategoryModel> _backendCategories = [];
  bool _isLoadingCategories = true;

  List<Map<String, dynamic>> _nearbyBranches = [];
  bool _isLoadingBranches = false;

  final List<({String label, IconData icon, double? lat, double? lon})> _quickLocationChips = const [
    (label: 'Near me', icon: Icons.near_me_rounded, lat: null, lon: null),
    (label: 'Thamel, Ktm', icon: Icons.location_on_rounded, lat: 27.7154, lon: 85.3123),
    (label: 'Jhamsikhel, Lalitpur', icon: Icons.location_on_rounded, lat: 27.6788, lon: 85.3123),
    (label: 'Lakeside, Pokhara', icon: Icons.location_on_rounded, lat: 28.2096, lon: 83.9595),
    (label: 'New Road', icon: Icons.location_on_rounded, lat: 27.7033, lon: 85.3135),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _loadUnreadCount();
    _fetchCategories();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final saved = await getIt<UserLocationService>().loadSavedLocation();
      if (saved != null && mounted) {
        setState(() {
          _selectedPlace = saved;
          _currentLocation = saved.formatted;
          _activeQuickChip = saved.district ?? saved.formatted;
        });
        _fetchNearbyBranches(lat: saved.lat, lng: saved.lon);
        return;
      }
    } catch (_) {}
    _fetchNearbyBranches(lat: 27.7172, lng: 85.3240); // default Kathmandu center
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await getIt<CategoryRemoteDataSource>().getCategories();
      if (mounted) {
        setState(() {
          _backendCategories = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _fetchNearbyBranches({required double lat, required double lng}) async {
    setState(() => _isLoadingBranches = true);
    try {
      final branches = await getIt<BranchRemoteDataSource>().getBranchesNear(
        lat: lat,
        lng: lng,
        radiusKm: 50.0,
        limit: 15,
      );
      if (mounted) {
        setState(() {
          _nearbyBranches = branches;
          _isLoadingBranches = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingBranches = false);
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await _inboxService.unreadCount();
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  Future<void> _openLocationSelector() async {
    final selected = await LocationSelectionModal.show(
      context,
      currentLocation: _currentLocation,
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedPlace = selected;
        _currentLocation = selected.formatted;
        _activeQuickChip = selected.district ?? selected.formatted;
      });
      // Persist user selection
      getIt<UserLocationService>().saveLocation(selected);
      context.read<OffersBloc>().add(
        FetchOffersRequested(
          lat: selected.lat,
          lng: selected.lon,
          radiusKm: 50,
          location: selected.district,
          page: 1,
          limit: 30,
          refresh: true,
        ),
      );
      _fetchNearbyBranches(lat: selected.lat, lng: selected.lon);
    }
  }

  void _onQuickChipSelected(({String label, IconData icon, double? lat, double? lon}) chip) {
    setState(() => _activeQuickChip = chip.label);
    if (chip.lat == null) {
      // Near me
      _openLocationSelector();
      return;
    }

    final newPlace = PlaceSuggestion(
      name: chip.label,
      formatted: chip.label,
      lat: chip.lat!,
      lon: chip.lon!,
      district: chip.label,
      confidence: 1.0,
    );

    setState(() {
      _currentLocation = chip.label;
      _selectedPlace = newPlace;
    });

    getIt<UserLocationService>().saveLocation(newPlace);

    context.read<OffersBloc>().add(
      FetchOffersRequested(
        lat: chip.lat,
        lng: chip.lon,
        radiusKm: 50,
        page: 1,
        limit: 30,
        refresh: true,
      ),
    );
    _fetchNearbyBranches(lat: chip.lat!, lng: chip.lon!);
  }

  void _navigateToSearch(String query, {String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          query: query,
          initialCategory: category,
          lat: _selectedPlace?.lat,
          lng: _selectedPlace?.lon,
          placeLabel: _currentLocation,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OffersBloc>().add(
              FetchOffersRequested(
                lat: _selectedPlace?.lat,
                lng: _selectedPlace?.lon,
                radiusKm: 50,
                location: _selectedPlace?.district,
                page: 1,
                limit: 30,
                refresh: true,
              ),
            );
            context.read<HomeBloc>().add(const HomeStarted());
            _fetchCategories();
            if (_selectedPlace != null) {
              _fetchNearbyBranches(lat: _selectedPlace!.lat, lng: _selectedPlace!.lon);
            }
          },
          color: AppTheme.crimsonPrimary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Top Bar matching homepage_sample.html ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Logo & Wordmark
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.borderLight, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/logo.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Location Selector Capsule
                          GestureDetector(
                            onTap: _openLocationSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 15,
                                    color: AppTheme.crimsonPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 95),
                                    child: Text(
                                      _currentLocation,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.expand_more_rounded,
                                    size: 15,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Actions: Notification & Avatar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              );
                              _loadUnreadCount();
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    size: 19,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (_unreadCount > 0)
                                  Positioned(
                                    top: 1,
                                    right: 1,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: AppTheme.crimsonPrimary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.cardSurface,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // Switch directly to Profile tab in MainShellScreen (preserving bottom navbar)
                              MainShellScreen.switchTab(context, 4);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.crimsonPrimary.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: AppTheme.textMuted,
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 20, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Floating Search Pill & Quick Location Chips ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Column(
                    children: [
                      // Floating Search Pill
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    _navigateToSearch(val.trim());
                                  }
                                },
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search momo, spa, weekend getaways...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            // Voice Mic trigger
                            GestureDetector(
                              onTap: () => _navigateToSearch('Momo'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.mic_rounded, size: 20, color: AppTheme.textMuted),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Tune Filter trigger
                            GestureDetector(
                              onTap: () => _navigateToSearch(_searchController.text.trim()),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: AppTheme.crimsonPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Location Chips Rail
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _quickLocationChips.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final chip = _quickLocationChips[index];
                            final isSelected = _activeQuickChip == chip.label;
                            return GestureDetector(
                              onTap: () => _onQuickChipSelected(chip),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.surfaceDark : AppTheme.cardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      chip.icon,
                                      size: 13,
                                      color: isSelected
                                          ? AppTheme.emeraldJade
                                          : AppTheme.crimsonPrimary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      chip.label,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 3. Dynamic Category Rail from Backend ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explore Categories',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSearch(''),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.crimsonPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppTheme.crimsonPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _isLoadingCategories
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: 8,
                          itemBuilder: (_, __) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: SkeletonLoader(
                                    height: double.infinity,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Row(
                                    children: [
                                      SkeletonLoader(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(10))),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: SkeletonLoader(width: double.infinity, height: 10, borderRadius: BorderRadius.all(Radius.circular(4))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: _backendCategories.isNotEmpty
                              ? _backendCategories.length
                              : _fallbackCategories.length,
                          itemBuilder: (context, index) {
                            if (_backendCategories.isNotEmpty) {
                              final cat = _backendCategories[index];
                              return _buildCategoryGridCard(
                                name: cat.name,
                                subtitle: _subtitleForCategory(cat.slug),
                                icon: _iconForCategory(cat.slug),
                                iconBgColor: _categoryBadgeColor(cat.slug, index),
                                imageUrl: cat.imageUrl,
                                fallbackAsset: _fallbackAssetForCategory(cat.slug),
                                onTap: () => _navigateToSearch('', category: cat.name),
                              );
                            } else {
                              final cat = _fallbackCategories[index];
                              return _buildCategoryGridCard(
                                name: cat.name,
                                subtitle: _subtitleForCategory(cat.name),
                                icon: cat.icon,
                                iconBgColor: cat.bgColor,
                                imageUrl: null,
                                fallbackAsset: _fallbackAssetForCategory(cat.name),
                                onTap: () => _navigateToSearch('', category: cat.name),
                              );
                            }
                          },
                        ),
                      ),
              ),

              // ── 4. Deal of the Day Spotlight Hero ────────────────────────
              SliverToBoxAdapter(
                child: BlocBuilder<OffersBloc, OffersState>(
                  builder: (context, state) {
                    if (state is OffersLoading) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: SkeletonLoader(height: 260, borderRadius: BorderRadius.circular(20)),
                      );
                    }

                    OfferEntity? dealOfTheDay;
                    if (state is OffersLoaded && state.offers.isNotEmpty) {
                      dealOfTheDay = state.offers.firstWhere(
                        (o) => o.isFeatured,
                        orElse: () => state.offers.first,
                      );
                    }

                    if (dealOfTheDay == null) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 20,
                                    color: AppTheme.crimsonPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deal of the Day',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.crimsonPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 13,
                                      color: AppTheme.crimsonPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ends in 4h 32m',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.crimsonPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Spotlight Card Container
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OfferDetailPage(offer: dealOfTheDay!),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 16:9 Media aspect
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: dealOfTheDay.imageUrl ??
                                              (dealOfTheDay.images.isNotEmpty
                                                  ? dealOfTheDay.images.first
                                                  : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80'),
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceDark),
                                        ),
                                        // Top Badges
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Row(
                                            children: [
                                              if (dealOfTheDay.discountPercentage != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.crimsonPrimary,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${dealOfTheDay.discountPercentage}% OFF',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.emeraldJade,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Save Rs. ${dealOfTheDay.estimatedSavingsNpr}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Social Proof Bottom Bar
                                        Positioned(
                                          bottom: 8,
                                          left: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.92),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFA36700)),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${dealOfTheDay.rating.toStringAsFixed(1)} ',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w800,
                                                        color: AppTheme.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      '(${dealOfTheDay.reviewsCount}+ reviews)',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        color: AppTheme.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.local_fire_department_rounded, size: 14, color: AppTheme.crimsonPrimary),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      dealOfTheDay.reviewsCount > 0
                                                          ? '${dealOfTheDay.reviewsCount}+ verified reviews'
                                                          : 'Popular Deal',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w800,
                                                        color: AppTheme.crimsonPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Card Content
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              dealOfTheDay.category.name.toUpperCase(),
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.textMuted,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text('•', style: TextStyle(color: AppTheme.textMuted)),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.verified_rounded, size: 13, color: AppTheme.emeraldJade),
                                            const SizedBox(width: 3),
                                            Text(
                                              dealOfTheDay.merchantName ?? 'Verified Partner',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          dealOfTheDay.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          dealOfTheDay.description,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            color: AppTheme.textMuted,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),

                                        // Pricing & Claim
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.canvasBg,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (dealOfTheDay.originalPriceNpr != null)
                                                    Text(
                                                      'Rs. ${dealOfTheDay.originalPriceNpr}',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 11.5,
                                                        color: AppTheme.textMuted,
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                    ),
                                                  Text(
                                                    'Rs. ${dealOfTheDay.discountedPriceNpr ?? (dealOfTheDay.originalPriceNpr ?? 0) - dealOfTheDay.estimatedSavingsNpr}',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w900,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => OfferDetailPage(offer: dealOfTheDay!),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.crimsonPrimary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  elevation: 1,
                                                ),
                                                child: Text(
                                                  'Claim Deal',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── 5. Exclusive Hot Drops (Horizontal Carousel) ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exclusive Hot Drops',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Top-rated flash savings within 50km',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSearch(''),
                        child: Text(
                          'See more',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: BlocBuilder<OffersBloc, OffersState>(
                  builder: (context, state) {
                    if (state is OffersLoading) {
                      return SizedBox(
                        height: 220,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, __) => SkeletonLoader(width: 220, height: 220, borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }

                    List<OfferEntity> offers = [];
                    if (state is OffersLoaded) {
                      offers = state.offers;
                    }

                    if (offers.isEmpty) return const SizedBox();

                    return SizedBox(
                      height: 230,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: offers.length > 6 ? 6 : offers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return _buildHorizontalOfferCard(offer);
                        },
                      ),
                    );
                  },
                ),
              ),

              // ── 6. Offer Merchants Near You (Within 50km Radius) ─────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offer Merchants Near You',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Active partner locations within 50km radius',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSearch(''),
                        child: Text(
                          'View all',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _isLoadingBranches
                    ? SizedBox(
                        height: 120,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, __) => SkeletonLoader(width: 200, height: 120, borderRadius: BorderRadius.circular(16)),
                        ),
                      )
                    : _nearbyBranches.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.storefront_rounded, color: AppTheme.crimsonPrimary, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Searching for partner branches near your selected area...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 135,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _nearbyBranches.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final b = _nearbyBranches[index];
                                final name = b['name'] ?? 'Branch';
                                final city = b['city'] ?? b['address'] ?? 'Kathmandu';
                                final distKm = b['distanceKm'];
                                final merchant = b['merchant'];
                                final merchantName = merchant != null ? merchant['name'] ?? name : name;
                                final merchantId = b['merchantId'] ?? (merchant != null ? merchant['id'] : null);
                                final logo = merchant != null ? merchant['logoUrl'] : null;

                                return GestureDetector(
                                  onTap: () {
                                    if (merchantId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MerchantDetailPage(
                                            merchantId: merchantId.toString(),
                                            merchantName: merchantName.toString(),
                                            logoUrl: logo?.toString(),
                                            branches: [
                                              RedemptionBranchInfo(
                                                id: b['id']?.toString() ?? '',
                                                name: name.toString(),
                                                address: b['address']?.toString() ?? '',
                                                district: city.toString(),
                                                lat: (b['latitude'] as num?)?.toDouble() ?? 27.7172,
                                                lng: (b['longitude'] as num?)?.toDouble() ?? 85.3240,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 220,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardSurface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppTheme.borderLight),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.storefront_rounded,
                                                color: AppTheme.crimsonPrimary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    merchantName,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      color: AppTheme.textMuted,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.crimsonPrimary),
                                                  const SizedBox(width: 3),
                                                  Expanded(
                                                    child: Text(
                                                      city,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        color: AppTheme.textMuted,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (distKm != null)
                                              Container(
                                                margin: const EdgeInsets.only(left: 6),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.emeraldJade.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${(distKm as num).toStringAsFixed(1)} km',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppTheme.emeraldJade,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),

              // ── 7. Trending Deals (Vertical Highlights) ───────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trending Deals',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Most claimed merchant privileges this week',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSearch(''),
                        child: Text(
                          'View all',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: BlocBuilder<OffersBloc, OffersState>(
                  builder: (context, state) {
                    if (state is OffersLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SkeletonLoader(height: 180, borderRadius: BorderRadius.circular(16)),
                      );
                    }

                    List<OfferEntity> offers = [];
                    if (state is OffersLoaded) {
                      offers = state.offers.where((o) => o.rating >= 4.0 || o.isFeatured).toList();
                      if (offers.isEmpty) offers = state.offers;
                    }

                    if (offers.isEmpty) return const SizedBox();

                    final trendingTop = offers.take(3).toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: trendingTop.map((offer) => _buildFeaturedVerticalCard(offer)).toList(),
                      ),
                    );
                  },
                ),
              ),

              // ── 8. Recent Deals (Newly Published) ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Deals',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSearch(''),
                        child: Text(
                          'See more',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: BlocBuilder<OffersBloc, OffersState>(
                  builder: (context, state) {
                    if (state is OffersLoading) {
                      return SizedBox(
                        height: 220,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, __) => SkeletonLoader(width: 220, height: 220, borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }

                    List<OfferEntity> offers = [];
                    if (state is OffersLoaded) {
                      offers = state.offers.reversed.toList();
                    }

                    if (offers.isEmpty) return const SizedBox();

                    return SizedBox(
                      height: 230,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: offers.length > 6 ? 6 : offers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return _buildHorizontalOfferCard(offers[index]);
                        },
                      ),
                    );
                  },
                ),
              ),

              // ── 9. Featured Deals (Staff Picks) ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Deals',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSearch(''),
                        child: Text(
                          'View all',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: BlocBuilder<OffersBloc, OffersState>(
                  builder: (context, state) {
                    if (state is OffersLoaded) {
                      final featuredList = state.offers.where((o) => o.isFeatured).toList();
                      final displayList = featuredList.isNotEmpty ? featuredList : state.offers.take(3).toList();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: displayList.map((offer) => _buildFeaturedVerticalCard(offer)).toList(),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),

              // ── 10. The OfferNepal Guarantee Trust Banner ──────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF131B2E),
                          Color(0xFF1B2640),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF131B2E).withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppTheme.emeraldJade, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'The OfferNepal Guarantee',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGuaranteePill(Icons.qr_code_2_rounded, 'Instant\nVouchers'),
                            _buildGuaranteePill(Icons.payments_rounded, 'Flexible\nPayments'),
                            _buildGuaranteePill(Icons.handshake_rounded, '100% Money\nBack Guarantee'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalOfferCard(OfferEntity offer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OfferDetailPage(offer: offer)),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: CachedNetworkImage(
                imageUrl: offer.imageUrl ??
                    (offer.images.isNotEmpty ? offer.images.first : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80'),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceDark),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.merchantName ?? 'Verified Partner',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${offer.discountedPriceNpr ?? (offer.originalPriceNpr ?? 0) - offer.estimatedSavingsNpr}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.crimsonPrimary,
                        ),
                      ),
                      if (offer.discountPercentage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldJade.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${offer.discountPercentage}% OFF',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.emeraldJade,
                            ),
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
    );
  }

  Widget _buildFeaturedVerticalCard(OfferEntity offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: offer.imageUrl ??
                      (offer.images.isNotEmpty ? offer.images.first : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceDark),
                ),
                if (offer.discountPercentage != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.crimsonPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${offer.discountPercentage}% OFF',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      offer.merchantName ?? 'Verified Partner',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.crimsonPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFA36700)),
                        const SizedBox(width: 2),
                        Text(
                          offer.rating.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  offer.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${offer.discountedPriceNpr ?? (offer.originalPriceNpr ?? 0) - offer.estimatedSavingsNpr}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OfferDetailPage(offer: offer)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.crimsonPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        elevation: 0,
                      ),
                      child: Text(
                        'Redeem Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
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

  IconData _iconForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'dining':
      case 'food':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'wellness':
      case 'spa':
        return Icons.spa_rounded;
      case 'activities':
      case 'entertainment':
        return Icons.sports_esports_rounded;
      case 'shopping':
      case 'retail':
        return Icons.shopping_bag_rounded;
      case 'travel':
      case 'getaways':
        return Icons.flight_takeoff_rounded;
      case 'beauty':
      case 'salon':
        return Icons.face_retouching_natural_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  Color _bgColorForIndex(int index) {
    final colors = [
      AppTheme.crimsonPrimary,
      const Color(0xFF82F5C1),
      const Color(0xFFE2E7FF),
      const Color(0xFFFFDDB8),
      const Color(0xFFDAE2FD),
      const Color(0xFFFFDADA),
    ];
    return colors[index % colors.length];
  }

  Color _iconColorForIndex(int index) {
    final colors = [
      Colors.white,
      const Color(0xFF00714E),
      AppTheme.crimsonPrimary,
      const Color(0xFF653E00),
      const Color(0xFF006C4A),
      const Color(0xFF920028),
    ];
    return colors[index % colors.length];
  }

  final List<({String name, IconData icon, Color bgColor, Color iconColor})> _fallbackCategories = const [
    (name: 'Dining', icon: Icons.restaurant_rounded, bgColor: AppTheme.crimsonPrimary, iconColor: Colors.white),
    (name: 'Wellness', icon: Icons.spa_rounded, bgColor: Color(0xFF82F5C1), iconColor: Color(0xFF00714E)),
    (name: 'Activities', icon: Icons.sports_esports_rounded, bgColor: Color(0xFFE2E7FF), iconColor: AppTheme.crimsonPrimary),
    (name: 'Shopping', icon: Icons.shopping_bag_rounded, bgColor: Color(0xFFFFDDB8), iconColor: Color(0xFF653E00)),
    (name: 'Getaways', icon: Icons.flight_takeoff_rounded, bgColor: Color(0xFFDAE2FD), iconColor: Color(0xFF006C4A)),
    (name: 'Salon', icon: Icons.face_retouching_natural_rounded, bgColor: Color(0xFFFFDADA), iconColor: Color(0xFF920028)),
  ];

  String _subtitleForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'dining':
      case 'food':
      case 'restaurant':
        return 'Great food';
      case 'hotel':
      case 'hotels':
      case 'getaways':
      case 'travel':
        return 'Comfort stay';
      case 'shop':
      case 'shopping':
      case 'retail':
        return 'Best deals';
      case 'electrical':
      case 'electronics':
        return 'Smart living';
      case 'wellness':
      case 'spa':
      case 'salon':
      case 'beauty':
        return 'Relax & refresh';
      case 'auto':
      case 'automotive':
        return 'Drive easy';
      case 'home':
        return 'Better living';
      case 'activities':
      case 'entertainment':
        return 'Explore more';
      default:
        return 'Top offers';
    }
  }

  Color _categoryBadgeColor(String slug, int index) {
    switch (slug.toLowerCase()) {
      case 'dining':
      case 'food':
      case 'restaurant':
        return const Color(0xFFDC2626); // red-600
      case 'hotel':
      case 'hotels':
      case 'travel':
      case 'getaways':
        return const Color(0xFF2563EB); // blue-600
      case 'shop':
      case 'shopping':
      case 'retail':
        return const Color(0xFFF59E0B); // amber-500
      case 'electrical':
      case 'electronics':
        return const Color(0xFF9333EA); // purple-600
      case 'wellness':
      case 'spa':
        return const Color(0xFF059669); // emerald-600
      case 'auto':
      case 'automotive':
        return const Color(0xFFE11D48); // rose-600
      case 'home':
        return const Color(0xFF1D4ED8); // blue-700
      case 'activities':
      case 'entertainment':
        return const Color(0xFF14B8A6); // teal-500
      default:
        return _iconColorForIndex(index);
    }
  }

  String? _fallbackAssetForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'dining':
      case 'food':
      case 'restaurant':
        return 'assets/category/dining.png';
      case 'hotel':
      case 'hotels':
      case 'travel':
      case 'getaways':
        return 'assets/category/hotels.png';
      case 'activities':
      case 'entertainment':
        return 'assets/category/activities.png';
      case 'shop':
      case 'shopping':
      case 'discounts':
        return 'assets/category/discounts.png';
      default:
        return null;
    }
  }

  Widget _buildCategoryGridCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required String? imageUrl,
    required String? fallbackAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top aspect image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(fallbackAsset, iconBgColor, icon),
                    )
                  else
                    _buildPlaceholderPhoto(fallbackAsset, iconBgColor, icon),
                ],
              ),
            ),
            // Bottom info bar (Icon badge + title + subtitle + arrow)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 4, 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconBgColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 11,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto(String? fallbackAsset, Color bgColor, IconData fallbackIcon) {
    if (fallbackAsset != null) {
      return Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: bgColor.withValues(alpha: 0.12),
          child: Center(
            child: Icon(fallbackIcon, size: 24, color: bgColor),
          ),
        ),
      );
    }
    return Container(
      color: bgColor.withValues(alpha: 0.12),
      child: Center(
        child: Icon(fallbackIcon, size: 24, color: bgColor),
      ),
    );
  }

  Widget _buildCategorySquare({
    required String name,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppTheme.crimsonPrimary : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteePill(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
