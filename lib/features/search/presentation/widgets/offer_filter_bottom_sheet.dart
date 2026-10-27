import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/home/data/datasources/category_remote_datasource.dart';

class OfferFilterCriteria {
  final double? radiusKm;
  final double? minRating;
  final int? minDiscountPercent;
  final String? category;

  const OfferFilterCriteria({
    this.radiusKm,
    this.minRating,
    this.minDiscountPercent,
    this.category,
  });

  bool get isEmpty =>
      radiusKm == null &&
      minRating == null &&
      minDiscountPercent == null &&
      category == null;

  int get activeCount {
    int count = 0;
    if (radiusKm != null) count++;
    if (minRating != null) count++;
    if (minDiscountPercent != null) count++;
    if (category != null) count++;
    return count;
  }

  OfferFilterCriteria copyWith({
    double? radiusKm,
    double? minRating,
    int? minDiscountPercent,
    String? category,
    bool clearRadius = false,
    bool clearRating = false,
    bool clearDiscount = false,
    bool clearCategory = false,
  }) {
    return OfferFilterCriteria(
      radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      minDiscountPercent: clearDiscount ? null : (minDiscountPercent ?? this.minDiscountPercent),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

class OfferFilterBottomSheet extends StatefulWidget {
  final OfferFilterCriteria initialCriteria;

  const OfferFilterBottomSheet({
    super.key,
    required this.initialCriteria,
  });

  static Future<OfferFilterCriteria?> show(
    BuildContext context, {
    required OfferFilterCriteria initialCriteria,
  }) {
    return showModalBottomSheet<OfferFilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OfferFilterBottomSheet(initialCriteria: initialCriteria),
    );
  }

  @override
  State<OfferFilterBottomSheet> createState() => _OfferFilterBottomSheetState();
}

class _OfferFilterBottomSheetState extends State<OfferFilterBottomSheet> {
  late double _radius;
  bool _radiusActive = false;
  double? _selectedRating;
  int? _selectedDiscount;
  String? _selectedCategory;

  List<CategoryModel> _availableCategories = [];
  bool _isLoadingCategories = true;

  final List<double> _ratingOptions = const [3.5, 4.0, 4.5];
  final List<int> _discountOptions = const [20, 30, 40, 50];

  @override
  void initState() {
    super.initState();
    if (widget.initialCriteria.radiusKm != null) {
      _radius = widget.initialCriteria.radiusKm!;
      _radiusActive = true;
    } else {
      _radius = 5.0;
      _radiusActive = false;
    }
    _selectedRating = widget.initialCriteria.minRating;
    _selectedDiscount = widget.initialCriteria.minDiscountPercent;
    _selectedCategory = widget.initialCriteria.category;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final ds = getIt<CategoryRemoteDataSource>();
      final cats = await ds.getCategories();
      if (mounted) {
        setState(() {
          _availableCategories = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _resetAll() {
    setState(() {
      _radius = 5.0;
      _radiusActive = false;
      _selectedRating = null;
      _selectedDiscount = null;
      _selectedCategory = null;
    });
  }

  void _apply() {
    final criteria = OfferFilterCriteria(
      radiusKm: _radiusActive ? _radius : null,
      minRating: _selectedRating,
      minDiscountPercent: _selectedDiscount,
      category: _selectedCategory,
    );
    Navigator.pop(context, criteria);
  }

  int get _currentActiveCount {
    int c = 0;
    if (_radiusActive) c++;
    if (_selectedRating != null) c++;
    if (_selectedDiscount != null) c++;
    if (_selectedCategory != null) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppTheme.borderMedium.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: AppTheme.crimsonPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Filter Offers',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _resetAll,
                  child: Text(
                    'Reset All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.crimsonPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderLight),

          // Scrollable Filter Sections
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Distance Radius
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distance Radius',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _radiusActive
                            ? 'Within ${_radius.toInt()} km'
                            : 'Any Distance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _radiusActive
                              ? AppTheme.crimsonPrimary
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.crimsonPrimary,
                      inactiveTrackColor: AppTheme.borderLight,
                      thumbColor: AppTheme.crimsonPrimary,
                      overlayColor: AppTheme.crimsonPrimary.withValues(alpha: 0.15),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _radius,
                      min: 1.0,
                      max: 30.0,
                      divisions: 29,
                      label: '${_radius.toInt()} km',
                      onChanged: (val) {
                        setState(() {
                          _radius = val;
                          _radiusActive = true;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 km', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
                      Text('15 km', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
                      Text('30 km', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 2. Minimum Rating
                  Text(
                    'Minimum Rating',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'Any Rating',
                        isSelected: _selectedRating == null,
                        onTap: () => setState(() => _selectedRating = null),
                      ),
                      ..._ratingOptions.map((rating) {
                        final isSelected = _selectedRating == rating;
                        return _buildChip(
                          label: '$rating+ Stars',
                          icon: Icons.star_rounded,
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            _selectedRating = isSelected ? null : rating;
                          }),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Minimum Discount
                  Text(
                    'Discount Percentage',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'Any Discount',
                        isSelected: _selectedDiscount == null,
                        onTap: () => setState(() => _selectedDiscount = null),
                      ),
                      ..._discountOptions.map((discount) {
                        final isSelected = _selectedDiscount == discount;
                        return _buildChip(
                          label: '$discount%+ OFF',
                          icon: Icons.percent_rounded,
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            _selectedDiscount = isSelected ? null : discount;
                          }),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. Categories
                  Text(
                    'Category',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingCategories)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          label: 'All Categories',
                          isSelected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        ..._availableCategories.map((cat) {
                          final isSelected =
                              _selectedCategory?.toLowerCase() == cat.name.toLowerCase() ||
                              _selectedCategory?.toLowerCase() == cat.slug.toLowerCase();
                          return _buildChip(
                            label: cat.name,
                            isSelected: isSelected,
                            onTap: () => setState(() {
                              _selectedCategory = isSelected ? null : cat.name;
                            }),
                          );
                        }),
                      ],
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.crimsonPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _currentActiveCount > 0
                      ? 'Apply Filters ($_currentActiveCount)'
                      : 'Show All Offers',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceDark : AppTheme.canvasBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.amberAccent : AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
