import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';
import 'package:entertainer/features/home/domain/entities/category_entity.dart';

class CategoryCard extends StatefulWidget {
  final Map<String, Map<String, String>> category;
  const CategoryCard({super.key, required this.category});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  int _selectedIndex = 0;

  // Curated pastel background tints directly matching the reference UI (Gaming, Tech, Streaming)
  final List<Color> _pastelPalette = const [
    AppTheme.accentPeriwinkle,
    AppTheme.accentMint,
    AppTheme.accentAmber,
    Color(0xFFFFB4AB),
    Color(0xFFB4C8FF),
    Color(0xFFE2D4FF),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = widget.category.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categories",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Popular",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 124,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              final isSelected = _selectedIndex == index;
              final pastelColor = _pastelPalette[index % _pastelPalette.length];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  context.read<HomeBloc>().add(CategorySelected(item.key));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 104,
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? pastelColor : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: AppTheme.softCardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.35) : AppTheme.canvasBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(item.key),
                            color: AppTheme.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.value['count'] ?? '12'} Offers",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppTheme.textPrimary.withValues(alpha: 0.7)
                              : AppTheme.textSecondary,
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
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('dining') || lower.contains('restaurant')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('beauty') || lower.contains('spa') || lower.contains('wellness')) {
      return Icons.spa_rounded;
    } else if (lower.contains('hotel') || lower.contains('stay') || lower.contains('travel')) {
      return Icons.hotel_rounded;
    } else if (lower.contains('activity') || lower.contains('entertain') || lower.contains('gaming')) {
      return Icons.sports_esports_rounded;
    } else if (lower.contains('tech') || lower.contains('gadget')) {
      return Icons.bolt_rounded;
    }
    return Icons.local_offer_rounded;
  }
}

/// A category row powered by real backend [CategoryEntity] objects.
/// Calls [onCategoryTap] with the category name when the user taps a chip.
class CategoryCardFromApi extends StatefulWidget {
  final List<CategoryEntity> categories;
  final void Function(String categoryName) onCategoryTap;

  const CategoryCardFromApi({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  State<CategoryCardFromApi> createState() => _CategoryCardFromApiState();
}

class _CategoryCardFromApiState extends State<CategoryCardFromApi> {
  int _selectedIndex = -1; // -1 = none selected (shows all)

  final List<Color> _pastelPalette = const [
    AppTheme.accentPeriwinkle,
    AppTheme.accentMint,
    AppTheme.accentAmber,
    Color(0xFFFFB4AB),
    Color(0xFFB4C8FF),
    Color(0xFFE2D4FF),
  ];

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dining') || lower.contains('food') || lower.contains('restaurant')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('wellness') || lower.contains('spa') || lower.contains('beauty')) {
      return Icons.spa_rounded;
    } else if (lower.contains('hotel') || lower.contains('travel') || lower.contains('stay')) {
      return Icons.hotel_rounded;
    } else if (lower.contains('activit') || lower.contains('entertain')) {
      return Icons.sports_esports_rounded;
    } else if (lower.contains('night') || lower.contains('bar') || lower.contains('club')) {
      return Icons.nightlife_rounded;
    } else if (lower.contains('retail') || lower.contains('shop') || lower.contains('store')) {
      return Icons.shopping_bag_rounded;
    }
    return Icons.local_offer_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              if (_selectedIndex >= 0)
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = -1);
                    widget.onCategoryTap('');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPeriwinkle.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentPeriwinkleDark.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 13, color: AppTheme.accentPeriwinkleDark),
                        SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentPeriwinkleDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderLight, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Popular',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 124,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              final isSelected = _selectedIndex == index;
              final color = _pastelPalette[index % _pastelPalette.length];
              return GestureDetector(
                onTap: () {
                  widget.onCategoryTap(cat.name);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 104,
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: AppTheme.softCardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.35)
                              : AppTheme.canvasBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _iconFor(cat.name),
                            color: AppTheme.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cat.offerCount} Offers',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppTheme.textPrimary.withValues(alpha: 0.7)
                              : AppTheme.textSecondary,
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
    );
  }
}
