import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'offer_detail_page.dart';

class CategoryOffersPage extends StatelessWidget {
  final String categoryName;

  const CategoryOffersPage({super.key, required this.categoryName});

  // Mock curated offers for the selected category
  List<Map<String, String>> _getCategoryOffers() {
    return [
      {
        "hotelName": "$categoryName Special Lounge",
        "distanceFromUser": "1.1 km away",
        "highlightTag": "BOGOF",
        "location": "Downtown City Center",
        "rating": "4.9",
        "discount": "Buy 1 Get 1 Free",
        "image": "https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80",
      },
      {
        "hotelName": "The Royal $categoryName Club",
        "distanceFromUser": "2.4 km away",
        "highlightTag": "2-for-1",
        "location": "North Boulevard",
        "rating": "4.8",
        "discount": "50% Off Total Bill",
        "image": "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/12/12/healthy-avo-food.jpg",
      },
      {
        "hotelName": "Urban $categoryName Oasis",
        "distanceFromUser": "3.2 km away",
        "highlightTag": "Exclusive",
        "location": "Harbor View Mall",
        "rating": "4.7",
        "discount": "Complimentary Starter",
        "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-GyDbcO4oFC8rngIjIlp4oHrvISS-xUkIpj5TUFqB9PYhco-8q06vFkAy&s=10",
      },
      {
        "hotelName": "Signature $categoryName Bistro",
        "distanceFromUser": "4.5 km away",
        "highlightTag": "Trending",
        "location": "The Marina Walk",
        "rating": "4.9",
        "discount": "Buy 1 Get 1 Entree",
        "image": "https://img.etimg.com/thumb/width-1200,height-1200,imgsize-1566631,resizemode-75,msid-128680152/news/new-updates/street-food-without-the-guilt-famous-cardiologist-shares-5-tasty-picks-that-are-healthy-and-easy-on-your-pocket.jpg",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final offers = _getCategoryOffers();

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: Stack(
        children: [

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderLight, width: 1.0),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "${offers.length} verified BOGOF spots nearby",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPeriwinkle.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune_rounded, size: 16, color: AppTheme.accentPeriwinkleDark),
                            const SizedBox(width: 4),
                            Text(
                              "Filter",
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentPeriwinkleDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Filter Tag Pills
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildFilterPill("All Offers", isSelected: true),
                      _buildFilterPill("Buy 1 Get 1 Free"),
                      _buildFilterPill("Top Rated 4.5+"),
                      _buildFilterPill("< 2 km"),
                      _buildFilterPill("New Additions"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Category Offers List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    physics: const BouncingScrollPhysics(),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final item = offers[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
                          boxShadow: AppTheme.softCardShadow,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OfferDetailPage(offer: {
                                  "hotelName": item["hotelName"]!,
                                  "location": item["location"]!,
                                  "distanceFromUser": item["distanceFromUser"]!,
                                  "highlightTag": item["highlightTag"]!,
                                  "image": item["image"]!,
                                }),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero image thumbnail with tags
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                    child: Image.network(
                                      item["image"]!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 150,
                                        color: const Color(0xFFD3E4FE),
                                        child: const Center(
                                          child: Icon(Icons.restaurant_rounded, size: 40, color: AppTheme.accentPeriwinkle),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                     child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.darkPill,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item["highlightTag"]!,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB800)),
                                          const SizedBox(width: 3),
                                          Text(
                                            item["rating"]!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Info body
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["hotelName"]!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16.5,
                                              color: Colors.black87,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.savingsGreen.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item["discount"]!,
                                            style: const TextStyle(
                                              color: AppTheme.savingsGreen,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accentPeriwinkle),
                                        const SizedBox(width: 4),
                                        Text(
                                          item["location"]!,
                                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.directions_walk_rounded, size: 14, color: AppTheme.savingsGreen),
                                        const SizedBox(width: 4),
                                        Text(
                                          item["distanceFromUser"]!,
                                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.darkPill : AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
