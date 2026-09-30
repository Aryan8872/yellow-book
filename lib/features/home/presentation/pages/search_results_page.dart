import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import 'map_discovery_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  String _selectedFilter = 'All';

  final List<String> _categories = ['All', 'Restaurants', 'Grocery', 'Drinks', 'Dining', 'Hotels'];
  final List<String> _filterChips = ['Sort', 'Free Delivery', 'Meal Voucher', 'Coupon'];

  final List<Map<String, String>> _mockResults = [
    {
      'name': 'Galeto Mamma Mia - Bela Vista',
      'category': 'Italian',
      'distance': '0.5 km',
      'time': '30-40 min',
      'price': '\$13.50',
      'rating': '4.8',
      'tag': 'BOGOF',
    },
    {
      'name': 'Canto do Sabor Kitchen & Grill',
      'category': 'Home Cooking',
      'distance': '1.1 km',
      'time': '40-50 min',
      'price': 'Free',
      'rating': '4.7',
      'tag': 'Free Delivery',
    },
    {
      'name': 'Jeronimo Burger & Fries',
      'category': 'Fast Food',
      'distance': '0.4 km',
      'time': '25-35 min',
      'price': '\$9.90',
      'rating': '4.9',
      'tag': 'Verified',
    },
    {
      'name': 'Tribes Restaurant - Downtown',
      'category': 'Dining',
      'distance': '1.2 km',
      'time': '20-30 min',
      'price': '\$15.00',
      'rating': '4.8',
      'tag': 'BOGOF',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _mockResults.where((item) {
      final matchesQuery = _searchController.text.isEmpty ||
          item['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          item['category']!.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD3E4FE),
      body: Stack(
        children: [
          // Background ambient glow blobs
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.2),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Search Bar with Back Button & Map Button (Same as Explore Page)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 20,
                          blur: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          color: Colors.white.withValues(alpha: 0.85),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF0053DB), size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => setState(() {}),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search restaurants, stores, locations...',
                                    hintStyle: GoogleFonts.inter(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      fontSize: 13.5,
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
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Map Button
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

                const SizedBox(height: 8),

                // 2. Category Chips Bar (Same as Explore Page)
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
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
                            color: isSelected ? null : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.9),
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
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Filter Chips (Extracted from Delivery UI)
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filterChips.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filterChips[index];
                      final isSelected = _selectedFilter == filter;
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? const Color(0xFF346EF6) : Colors.black87,
                              ),
                            ),
                            if (index == 0 || index == 2) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: isSelected ? const Color(0xFF346EF6) : Colors.black87,
                              ),
                            ],
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = selected ? filter : 'All';
                          });
                        },
                        backgroundColor: Colors.white.withValues(alpha: 0.75),
                        selectedColor: const Color(0xFF346EF6).withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF346EF6) : Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Search Results List
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 48, color: Colors.black38),
                              const SizedBox(height: 12),
                              Text(
                                'No stores or offers found for "${_searchController.text}"',
                                style: GoogleFonts.inter(color: Colors.black54, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                borderRadius: 20,
                                blur: 16,
                                padding: const EdgeInsets.all(14),
                                color: Colors.white.withValues(alpha: 0.85),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF346EF6).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.store_rounded, color: Color(0xFF346EF6), size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name']!,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.black87),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${item['category']} • ${item['distance']} • ${item['time']}',
                                            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                              const SizedBox(width: 2),
                                              Text(
                                                item['rating']!,
                                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                item['price']!,
                                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
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
