import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

class MapFilterSelection {
  final String category;
  final double radiusKm;
  final double minimumRating;
  final bool onlyOpenNow;

  const MapFilterSelection({
    required this.category,
    required this.radiusKm,
    required this.minimumRating,
    this.onlyOpenNow = false,
  });
}

class MapFiltersSheet extends StatefulWidget {
  final String category;
  final double radiusKm;
  final double minimumRating;
  final bool onlyOpenNow;

  const MapFiltersSheet({
    super.key,
    required this.category,
    required this.radiusKm,
    required this.minimumRating,
    this.onlyOpenNow = false,
  });

  @override
  State<MapFiltersSheet> createState() => _MapFiltersSheetState();
}

class _MapFiltersSheetState extends State<MapFiltersSheet> {
  static const _categories = [
    'All',
    'Dining',
    'Wellness',
    'Entertainment',
    'Retail',
    'Travel',
    'Beauty',
  ];

  late String _category = widget.category;
  late double _radiusKm = widget.radiusKm;
  late double _minimumRating = widget.minimumRating;
  late bool _onlyOpenNow = widget.onlyOpenNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Filter map offers',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Category', style: _labelStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categories.contains(_category) ? _category : 'All',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Radius', style: _labelStyle),
                const Spacer(),
                Text('${_radiusKm.round()} km', style: _labelStyle),
              ],
            ),
            Slider(
              value: _radiusKm.clamp(5, 100),
              min: 5,
              max: 100,
              divisions: 19,
              label: '${_radiusKm.round()} km',
              onChanged: (value) => setState(() => _radiusKm = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Minimum rating', style: _labelStyle),
                const Spacer(),
                Text(
                  _minimumRating == 0
                      ? 'Any'
                      : '${_minimumRating.toStringAsFixed(1)}+',
                  style: _labelStyle,
                ),
              ],
            ),
            Slider(
              value: _minimumRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: _minimumRating == 0
                  ? 'Any'
                  : _minimumRating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _minimumRating = value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text('Open Now / Operating Hours', style: _labelStyle),
              subtitle: Text(
                'Show places currently open based on operating hours',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              value: _onlyOpenNow,
              activeColor: AppTheme.savingsGreen,
              onChanged: (value) => setState(() => _onlyOpenNow = value),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  MapFilterSelection(
                    category: _category,
                    radiusKm: _radiusKm,
                    minimumRating: _minimumRating,
                    onlyOpenNow: _onlyOpenNow,
                  ),
                ),
                child: const Text('Apply filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
  );
}
