import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/services/user_location_service.dart';
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
    // Persist to secure storage so the chosen location survives app restarts
    // and is not overwritten by the GPS Narayanhiti fallback.
    getIt<UserLocationService>().saveLocation(place);
    // Persist to secure storage so the chosen location survives app restarts
    // and is not overwritten by the GPS Narayanhiti fallback.
    getIt<UserLocationService>().saveLocation(place);
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
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                        ),
                  hintText: 'Search any place in Nepal',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMuted,
                  ),
                  filled: true,
                  fillColor: AppTheme.cardSurface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
   
