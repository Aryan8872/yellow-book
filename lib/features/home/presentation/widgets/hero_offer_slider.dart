import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HeroOfferSlider extends StatefulWidget {
  final List<String> images;

  const HeroOfferSlider({super.key, required this.images});

  @override
  State<HeroOfferSlider> createState() => _HeroOfferSliderState();
}

class _HeroOfferSliderState extends State<HeroOfferSlider> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                // Shimmer placeholder while loading
                placeholder: (context, url) => Container(
                  color: const Color(0xFFD3E4FE),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF346EF6),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
