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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
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
