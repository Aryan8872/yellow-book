import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import 'offer_detail_page.dart';
import 'map_discovery_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Dining',
    'Hotels',
    'Activities',
    'Offers',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E4FE),
      body: Stack(
        children: [
          // Background subtle ambient glow blobs
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            top: 280,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF346EF6).withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Explore & Search",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Find 1,000+ Buy 1 Get 1 Free spots across the city",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Frosted Glass Search Input Bar with Map Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 20,
                          blur: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          color: Colors.white.withValues(alpha: 0.8),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF0053DB), size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    context.read<SearchBloc>().add(SearchQueryChanged(value));
                                  },
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search restaurants, hotels, dishes...',
                                    hintStyle: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<SearchBloc>().add(const SearchCleared());
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Dedicated Map Discovery Action Button
                      GlassContainer(
                        borderRadius: 20,
                        blur: 16,
                        padding: EdgeInsets.zero,
                        color: Colors.white.withValues(alpha: 0.85),
                        border: Border.all(
                          color: const Color(0xFF346EF6).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0053DB).withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.map_rounded, color: Colors.white, size: 24),
                            tooltip: 'Open Interactive Map',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MapDiscoveryPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Category Filter Pills
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    final currentCategory = state is SearchSuccessState ? state.activeCategory : 'All';

                    return SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = currentCategory == category;

                          return GestureDetector(
                            onTap: () {
                              context.read<SearchBloc>().add(SearchCategoryFilterApplied(category));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withValues(alpha: 0.85),
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF0053DB).withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Results Counter & Filter indicator
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    final results = state is SearchSuccessState ? state.results : [];
                    final query = state is SearchSuccessState ? state.query : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            query.isNotEmpty ? "Results for \"$query\"" : "Recommended for You",
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${results.length} Offers",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Search Results Grid/List
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchLoadingState) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF346EF6)),
                        );
                      }

                      final results = state is SearchSuccessState ? state.results : [];

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
                        physics: const BouncingScrollPhysics(),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final item = results[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: GlassContainer(
                              borderRadius: 20,
                              blur: 16,
                              padding: const EdgeInsets.all(12),
                              color: Colors.white.withValues(alpha: 0.8),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OfferDetailPage(offer: {
                                      "hotelName": item["hotelName"]!,
                                      "location": item["location"]!,
                                      "distanceFromUser": item["distanceFromUser"]!,
                                      "highlightTag": item["highlightTag"]!,
                                      "image": item["image"]!,
                                    }),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  // Offer Image Thumbnail with Tag
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          item["image"]!,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 90,
                                            height: 90,
                                            color: const Color(0xFFD3E4FE),
                                            child: const Icon(Icons.restaurant_rounded, color: Color(0xFF346EF6), size: 28),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item["highlightTag"]!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Details Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item["hotelName"]!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.5,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                                                const SizedBox(width: 2),
                                                Text(
                                                  item["rating"] ?? '4.8',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11.5,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item["offerType"] ?? 'Buy 1 Get 1 Free',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF059669),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF346EF6)),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                item["location"]!,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              item["distanceFromUser"]!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black45,
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
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
