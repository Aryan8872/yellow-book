import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/offer/data/datasource/places_remote_datasource.dart';

/// Autocomplete search dropdown for the map discovery page.
/// Matches the web FloatingMapSearch glassmorphism dropdown design.
/// Note: This widget now only renders the suggestions list.
/// The search input TextField is in the page header (map_discovery_page.dart).
class MapSearchOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> merchants;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Map<String, dynamic>> onMerchantSelected;
  final ValueChanged<PlaceSuggestion> onPlaceSelected;
  final VoidCallback onClear;
  final double? currentLat;
  final double? currentLng;

  const MapSearchOverlay({
    super.key,
    required this.merchants,
    required this.controller,
    required this.onQueryChanged,
    required this.onMerchantSelected,
    required this.onPlaceSelected,
    required this.onClear,
    this.currentLat,
    this.currentLng,
  });

  @override
  State<MapSearchOverlay> createState() => _MapSearchOverlayState();
}

class _MapSearchOverlayState extends State<MapSearchOverlay> {
  bool _showSuggestions = false;
  bool _suppressNextSearchChange = false;
  Timer? _debounce;
  final PlacesRemoteDataSource _placesDataSource = PlacesRemoteDataSource();
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _placesLoading = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (_suppressNextSearchChange) {
      _suppressNextSearchChange = false;
      _debounce?.cancel();
      setState(() => _showSuggestions = false);
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = widget.controller.text.trim();
      setState(() => _showSuggestions = query.isNotEmpty);
      if (query.isNotEmpty) {
        _performPlacesSearch(query);
      } else {
        _placeSuggestions = [];
      }
    });
  }

  Future<void> _performPlacesSearch(String query) async {
    setState(() {
      _placesLoading = true;
    });

    try {
      final results = await _placesDataSource.searchPlaces(
        query: query,
        lat: widget.currentLat,
        lon: widget.currentLng,
      );
      if (mounted) {
        setState(() {
          _placeSuggestions = results;
          _placesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _placesLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _suggestions {
    final q = widget.controller.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return widget.merchants
        .where((m) {
          final name = (m['hotelName'] as String? ?? '').toLowerCase();
          final loc = (m['location'] as String? ?? '').toLowerCase();
          final branch = (m['branchName'] as String? ?? '').toLowerCase();
          final tag = (m['highlightTag'] as String? ?? '').toLowerCase();
          return name.contains(q) || loc.contains(q) || branch.contains(q) || tag.contains(q);
        })
        .take(6)
        .toList();
  }

  void _onSelect(Map<String, dynamic> merchant) {
    _debounce?.cancel();
    _suppressNextSearchChange = true;
    widget.controller.clear();
    setState(() {
      _showSuggestions = false;
      _placeSuggestions = [];
    });
    widget.onQueryChanged('');
    widget.onMerchantSelected(merchant);
  }

  void _onPlaceSelected(PlaceSuggestion place) {
    _debounce?.cancel();
    _suppressNextSearchChange = true;
    widget.controller.clear();
    setState(() {
      _showSuggestions = false;
      _placeSuggestions = [];
    });
    widget.onQueryChanged('');
    widget.onPlaceSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;
    final hasContent =
        _showSuggestions &&
        (suggestions.isNotEmpty ||
            _placeSuggestions.isNotEmpty ||
            _placesLoading);

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // MATCHING VENUES group
          if (suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'MATCHING VENUES (${suggestions.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final merchant = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    dense: true,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          merchant['image'] != null &&
                              merchant['image'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                merchant['image'].toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.store_rounded,
                                  size: 20,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.store_rounded,
                              size: 20,
                              color: AppTheme.textMuted,
                            ),
                    ),
                    title: Text(
                      merchant['hotelName'] as String? ?? 'Unknown',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      merchant['location'] as String? ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing:
                        merchant['highlightTag'] != null &&
                            merchant['highlightTag'].toString().isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.savingsGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.savingsGreen),
                            ),
                            child: Text(
                              merchant['highlightTag'] as String? ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.savingsGreen,
                              ),
                            ),
                          )
                        : null,
                    onTap: () => _onSelect(merchant),
                  ),
                ],
              );
            }),
          ],
          // PLACES group
          if (_placesLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  SkeletonLoader(height: 48),
                  SizedBox(height: 8),
                  SkeletonLoader(height: 48),
                  SizedBox(height: 8),
                  SkeletonLoader(height: 48),
                ],
              ),
            )
          else if (_placeSuggestions.isNotEmpty) ...[
            if (suggestions.isNotEmpty)
              const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'PLACES (${_placeSuggestions.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ..._placeSuggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final place = entry.value;
              return Column(
                children: [
                  if (index > 0 || suggestions.isNotEmpty)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    dense: true,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.place_rounded,
                        color: Color(0xFF667EEA),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      place.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: place.district != null && place.confidence < 0.5
                        ? Text(
                            place.district!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          )
                        : null,
                    onTap: () => _onPlaceSelected(place),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}
