import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/skeleton_loader.dart';
import 'package:entertainer/features/home/data/datasources/category_remote_datasource.dart';

class CategoryPillRow extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategory;
  final Function(String? category) onSelected;
  final bool isLoading;
  final bool hasError;

  const CategoryPillRow({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelected,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading();
    }

    if (hasError) {
      return const SizedBox.shrink();
    }

    return _buildContent();
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(right: 8),
          child: SkeletonLoader(height: 36, width: 80),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Prepend 'All' pill
    final items = ['All', ...categories.map((c) => c.name)];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedCategory == item || (item == 'All' && selectedCategory == null);

          return GestureDetector(
            onTap: () => onSelected(item == 'All' ? null : item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.darkPill : AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: isSelected ? null : Border.all(color: AppTheme.borderLight),
                boxShadow: isSelected ? [] : AppTheme.softCardShadow,
              ),
              child: Text(
                item,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
