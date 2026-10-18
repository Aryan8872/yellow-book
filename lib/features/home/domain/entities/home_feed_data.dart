import 'category_entity.dart';
import 'review_entity.dart';
import '../../../offer/domain/entity/offer_entity.dart';

class HomeFeedData {
  final List<String> heroSliderImages;
  final List<CategoryEntity> categories;
  final List<OfferEntity> trendingOffers;
  final List<OfferEntity> featuredOffers;
  final List<OfferEntity> popularOffers;
  final List<ReviewEntity> communityReviews;

  const HomeFeedData({
    required this.heroSliderImages,
    required this.categories,
    required this.trendingOffers,
    required this.featuredOffers,
    required this.popularOffers,
    required this.communityReviews,
  });
}
