import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/home/presentation/bloc/home_bloc.dart';
import 'package:entertainer/features/home/presentation/bloc/home_event.dart';

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
