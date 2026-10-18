import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Autocomplete search dropdown for the map discovery page.
/// Matches the web FloatingMapSearch glassmorphism dropdown design.
class MapSearchOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> merchants;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Map<String, dynamic>> onMerchantSelected;
  final VoidCallback onClear;

  const MapSearchOverlay({
    super.key,
    required this.merchants,
    required this.controller,
    required this.onQueryChanged,
    required this.onMerchantSelected,
    required this.onClear,
  });

  @override
  State<MapSearchOverlay> createState() => _MapSearchOverlayState();
}

class _MapSearchOverlayState extends State<MapSearchOverlay> {
  bool _showSuggestions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _showSuggestions = _focusNode.hasFocus && widget.controller.text.trim().isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _suggestions {
    final q = widget.controller.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return widget.merchants.where((m) {
      final name = (m['hotelName'] as String? ?? '').toLowerCase();
      final loc = (m['location'] as String? ?? '').toLowerCase();
      final tag = (m['highlightTag'] as String? ?? '').toLowerCase();
      return name.contains(q) || loc.contains(q) || tag.contains(q);
    }).take(6).toList();
  }

  void _onTextChanged(String value) {
    widget.onQueryChanged(value);
    if (mounted) setState(() => _showSuggestions = value.trim().isNotEmpty);
  }

  void _onSelect(Map<String, dynamic> merchant) {
    widget.controller.text = merchant['hotelName'] as String? ?? '';
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
    widget.onMerchantSelected(merchant);
  }

  void _onClear() {
    widget.controller.clear();
    widget.onClear();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search Input ───────────────────────────────────────────────────
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(24),
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
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: _onTextChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search venues, areas, tags...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: _onClear,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.close_rounded, size: 18, color: AppTheme.textSecondary),
                  ),
                ),
            ],
          ),
        ),

        // ── Autocomplete Dropdown ──────────────────────────────────────────
        if (_showSuggestions && suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Text(
                    'MATCHING VENUES (${suggestions.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted, letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0x18000000)),
                ...suggestions.map((m) => _SuggestionTile(
                  merchant: m,
                  onTap: () => _onSelect(m),
                )),
              ],
            ),
          ),
        ],

        if (_showSuggestions && widget.controller.text.trim().isNotEmpty && suggestions.isEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_off_rounded, color: AppTheme.textMuted, size: 18),
                const SizedBox(width: 10),
                Text(
                  'No venues found',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final Map<String, dynamic> merchant;
  final VoidCallback onTap;

  const _SuggestionTile({required this.merchant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = merchant['hotelName'] as String? ?? '';
    final location = merchant['location'] as String? ?? '';
    final category = merchant['category'] as String? ?? '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFD93025).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.place_rounded, color: Color(0xFFD93025), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$category · $location',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
