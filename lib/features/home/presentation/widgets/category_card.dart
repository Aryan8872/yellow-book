import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
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

  @override
  Widget build(BuildContext context) {
    final categories = widget.category.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Curated Categories",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.category.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              final isSelected = _selectedIndex == index;

              return Container(
                width: 86,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: GlassContainer(
                  borderRadius: 20,
                  blur: 14,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.6),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF346EF6)
                        : Colors.white.withValues(alpha: 0.8),
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    // Trigger BLoC event to navigate to Category Offers page
                    context.read<HomeBloc>().add(CategorySelected(item.key));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF346EF6).withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          item.value["image"]!,
                          height: 28,
                          width: 28,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.category_rounded,
                            size: 24,
                            color: isSelected ? const Color(0xFF346EF6) : Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.key,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12,
                          color: isSelected ? const Color(0xFF0053DB) : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
