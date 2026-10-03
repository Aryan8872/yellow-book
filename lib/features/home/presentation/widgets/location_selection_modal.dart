import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

class LocationOption {
  final String name;
  final String district;
  final String icon;

  const LocationOption({
    required this.name,
    required this.district,
    required this.icon,
  });
}

class LocationSelectionModal extends StatefulWidget {
  final String currentLocation;
  final ValueChanged<String> onLocationSelected;

  const LocationSelectionModal({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  static Future<String?> show(BuildContext context, {required String currentLocation}) {
    return Navigator.push<String>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LocationSelectionModal(
          currentLocation: currentLocation,
          onLocationSelected: (loc) => Navigator.pop(context, loc),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDistrict = 'All';

  // Primary operational locations in Nepal: Kathmandu, Chitwan, Jhapa
  static const List<LocationOption> _allLocations = [
    // Kathmandu District
    LocationOption(name: 'Thamel', district: 'Kathmandu', icon: '🏮'),
    LocationOption(name: 'Durbar Marg', district: 'Kathmandu', icon: '🏛️'),
    LocationOption(name: 'Jhamsikhel', district: 'Kathmandu', icon: '☕'),
    LocationOption(name: 'Lazimpat', district: 'Kathmandu', icon: '🏨'),
    LocationOption(name: 'Baluwatar', district: 'Kathmandu', icon: '🌳'),
    LocationOption(name: 'New Road', district: 'Kathmandu', icon: '🛍️'),
    LocationOption(name: 'Boudha', district: 'Kathmandu', icon: '☸️'),
    LocationOption(name: 'Patan Durbar Square', district: 'Kathmandu', icon: '🛕'),
    LocationOption(name: 'Koteshwor', district: 'Kathmandu', icon: '🚌'),
    LocationOption(name: 'Baneshwor', district: 'Kathmandu', icon: '🏢'),

    // Chitwan District
    LocationOption(name: 'Bharatpur', district: 'Chitwan', icon: '🏙️'),
    LocationOption(name: 'Sauraha', district: 'Chitwan', icon: '🦏'),
    LocationOption(name: 'Narayangarh', district: 'Chitwan', icon: '🌉'),
    LocationOption(name: 'Ratnanagar', district: 'Chitwan', icon: '🌿'),
    LocationOption(name: 'Meghauli', district: 'Chitwan', icon: '🐘'),
    LocationOption(name: 'Kasara', district: 'Chitwan', icon: '🛶'),

    // Jhapa District
    LocationOption(name: 'Birtamode', district: 'Jhapa', icon: '🏬'),
    LocationOption(name: 'Damak', district: 'Jhapa', icon: '🌇'),
    LocationOption(name: 'Bhadrapur', district: 'Jhapa', icon: '✈️'),
    LocationOption(name: 'Kakarvitta', district: 'Jhapa', icon: '🛂'),
    LocationOption(name: 'Surunga', district: 'Jhapa', icon: '🌾'),
    LocationOption(name: 'Arjundhara', district: 'Jhapa', icon: '⛩️'),
  ];

  static final List<String> _recentSearches = [
    'Thamel, Kathmandu',
    'Sauraha, Chitwan',
    'Birtamode, Jhapa',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LocationOption> get _filteredLocations {
    final query = _searchController.text.trim().toLowerCase();
    return _allLocations.where((loc) {
      final matchesDistrict = _selectedDistrict == 'All' || loc.district == _selectedDistrict;
      final matchesQuery = query.isEmpty ||
          loc.name.toLowerCase().contains(query) ||
          loc.district.toLowerCase().contains(query);
      return matchesDistrict && matchesQuery;
    }).toList();
  }

  void _selectLocation(String fullLocation) {
    if (!_recentSearches.contains(fullLocation)) {
      _recentSearches.insert(0, fullLocation);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }
    widget.onLocationSelected(fullLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: AppTheme.canvasBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: AppTheme.softCardShadow,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: Text(
          'Change Location',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 1. Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: false,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search Thamel, Bharatpur, Damak...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 2. Set Current Location Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {
                  _selectLocation('Current Location (Kathmandu)');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentPeriwinkle.withValues(alpha: 0.3)),
                    boxShadow: AppTheme.softCardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.pastelPeriwinkle.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: AppTheme.accentPeriwinkleDark,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set Current Location',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Using device GPS coordinates',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. District Filter Pills (Kathmandu, Chitwan, Jhapa)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['All', 'Kathmandu', 'Chitwan', 'Jhapa'].map((district) {
                    final isSelected = _selectedDistrict == district;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDistrict = district;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.darkPill : AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.darkPill : AppTheme.borderLight,
                          ),
                          boxShadow: isSelected ? AppTheme.softCardShadow : null,
                        ),
                        child: Text(
                          district == 'All' ? 'All Districts' : '$district District',
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Recent Searches
            if (_searchController.text.isEmpty && _recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Recent Searches',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((rec) {
                    return InkWell(
                      onTap: () => _selectLocation(rec),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history_rounded, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              rec,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Popular Areas in Nepal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 5. Locations List
            Expanded(
              child: _filteredLocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off_rounded, size: 40, color: AppTheme.textMuted),
                          const SizedBox(height: 10),
                          Text(
                            'No places found for "${_searchController.text}"',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredLocations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final loc = _filteredLocations[index];
                        final fullText = '${loc.name}, ${loc.district}';
                        final isSelected = widget.currentLocation.toLowerCase().contains(loc.name.toLowerCase());

                        return InkWell(
                          onTap: () => _selectLocation(fullText),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppTheme.accentPeriwinkleDark : AppTheme.borderLight,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: AppTheme.softCardShadow,
                            ),
                            child: Row(
                              children: [
                                Text(loc.icon, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${loc.district} District, Nepal',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkPill,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'SELECTED',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
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
    );
  }
}
