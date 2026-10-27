import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/map/presentation/pages/map_discovery_page.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';

class LocationSelectionModal extends StatefulWidget {
  final String currentLocation;
  final ValueChanged<PlaceSuggestion> onLocationSelected;

  const LocationSelectionModal({
    super.key,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  static Future<PlaceSuggestion?> show(
    BuildContext context, {
    required String currentLocation,
  }) {
    return Navigator.push<PlaceSuggestion>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LocationSelectionModal(
              currentLocation: currentLocation,
              onLocationSelected: (place) => Navigator.pop(context, place),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  final PlacesRemoteDataSource _placesDataSource = PlacesRemoteDataSource();
  Timer? _searchDebounce;
  List<PlaceSuggestion> _places = [];
  bool _isSearching = false;
  bool _isGettingLocation = false;
  int _searchRequestId = 0;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      setState(() {
        _places = [];
        _isSearching = false;
      });
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchPlaces(normalizedQuery),
    );
  }

  Future<void> _searchPlaces(String query) async {
    final requestId = ++_searchRequestId;
    setState(() => _isSearching = true);
    final results = await _placesDataSource.searchPlaces(query: query);
    if (!mounted || requestId != _searchRequestId) return;
    setState(() {
      _places = results;
      _isSearching = false;
    });
  }

  Future<void> _setCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage('Turn on location services to use your current location.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        _showMessage('Allow location access or search for a place instead.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      final reverse = await _placesDataSource.reverse(
        lat: position.latitude,
        lon: position.longitude,
      );
      final label = reverse.isEmpty ? 'Current location' : reverse.first.name;
      _selectPlace(
        PlaceSuggestion(
          formatted: label,
          name: label,
          lat: position.latitude,
          lon: position.longitude,
          confidence: 1,
        ),
      );
    } on TimeoutException {
      _showMessage(
        'Could not get a fresh location. Search for a place instead.',
      );
    } on LocationServiceDisabledException {
      _showMessage('Turn on location services to use your current location.');
    } on PermissionDeniedException {
      _showMessage('Allow location access or search for a place instead.');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _setLocationOnMap() async {
    final place = await Navigator.push<PlaceSuggestion>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapDiscoveryPage(locationPicker: true),
      ),
    );
    if (place != null && mounted) _selectPlace(place);
  }

  void _selectPlace(PlaceSuggestion place) {
    widget.onLocationSelected(place);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: AppTheme.canvasBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose location',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  hintText: 'Search any place in Nepal',
                  filled: true,
                  fillColor: AppTheme.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.my_location_rounded,
                    title: 'Set current location',
                    subtitle: 'Use a fresh GPS location',
                    isLoading: _isGettingLocation,
                    onTap: _isGettingLocation ? null : _setCurrentLocation,
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.map_outlined,
                    title: 'Set on map',
                    subtitle: 'Search a place or move the map pin',
                    onTap: _setLocationOnMap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                _searchController.text.trim().length < 2
                    ? 'Current selection: ${widget.currentLocation}'
                    : 'Search results',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _places.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.trim().length < 2
                            ? 'Search for a town, neighborhood, or landmark.'
                            : 'No matching places found.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: _places.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final place = _places[index];
                        return _PlaceTile(
                          place: place,
                          onTap: () => _selectPlace(place),
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: AppTheme.cardSurface,
      leading: Icon(icon, color: AppTheme.accentPeriwinkleDark),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final PlaceSuggestion place;
  final VoidCallback onTap;

  const _PlaceTile({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: AppTheme.cardSurface,
      leading: const Icon(
        Icons.location_on_outlined,
        color: AppTheme.accentPeriwinkleDark,
      ),
      title: Text(
        place.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(place.formatted),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
