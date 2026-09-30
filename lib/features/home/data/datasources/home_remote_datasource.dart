import '../model/offer_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<OfferModel>> fetchTrendingOffers();
  Future<List<OfferModel>> fetchFeaturedOffers();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<OfferModel>> fetchTrendingOffers() async {
    return const [
      OfferModel(
        id: '1',
        merchantName: 'Tribes',
        title: 'Buy 1 Get 1 Free Main Course',
        description: 'Valid on all pastas, steaks, signature entrees & pizzas.',
        category: 'Dining',
        location: 'The Dubai Mall',
        distance: '1.2 km away',
        highlightTag: 'BOGOF',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
      OfferModel(
        id: '2',
        merchantName: 'Green Bowl',
        title: 'Buy 1 Get 1 Free Salad & Smoothie',
        description: 'Valid on all gourmet salads and fresh juices.',
        category: 'Healthy',
        location: 'Kathmandu',
        distance: '2.5 km away',
        highlightTag: 'Healthy',
        imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
      OfferModel(
        id: '3',
        merchantName: 'Spicy Hub',
        title: 'Buy 1 Get 1 Free Nepalese Thali',
        description: 'Valid on authentic local dining platters.',
        category: 'Local',
        location: 'Lalitpur',
        distance: '3.1 km away',
        highlightTag: 'Local',
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
      OfferModel(
        id: '4',
        merchantName: 'Urban Bites',
        title: 'Buy 1 Get 1 Free Burger Meal',
        description: 'Valid on all artisan burgers and fries.',
        category: 'Street Food',
        location: 'Bhaktapur',
        distance: '4.0 km away',
        highlightTag: 'Street Food',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
    ];
  }

  @override
  Future<List<OfferModel>> fetchFeaturedOffers() async {
    return const [
      OfferModel(
        id: '5',
        merchantName: 'Paang Asian',
        title: 'Buy 1 Get 1 Free Dim Sum Platter',
        description: 'Authentic pan-Asian delicacy.',
        category: 'Dining',
        location: 'Thamel',
        distance: '1.5 km',
        highlightTag: 'BOGOF',
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
      OfferModel(
        id: '6',
        merchantName: 'Himalayan Java',
        title: 'Buy 1 Get 1 Free Espresso Beverage',
        description: 'Premium roasted specialty coffee.',
        category: 'Coffee',
        location: 'Durbar Marg',
        distance: '0.8 km',
        highlightTag: 'Coffee',
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
      OfferModel(
        id: '7',
        merchantName: 'Roadhouse Cafe',
        title: 'Buy 1 Get 1 Free Woodfired Pizza',
        description: 'Freshly baked woodfired specialty pizza.',
        category: 'Dining',
        location: 'Jhamsikhel',
        distance: '2.1 km',
        highlightTag: 'BOGOF',
        imageUrl: 'https://images.unsplash.com/photo-1578474846511-04ba529f0b88?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
      OfferModel(
        id: '8',
        merchantName: 'Bhojan Griha',
        title: 'Buy 1 Get 1 Free Cultural Meal',
        description: 'Traditional Nepalese organic cuisine.',
        category: 'Cultural',
        location: 'Dillibazar',
        distance: '3.4 km',
        highlightTag: 'Cultural',
        imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80',
        expiryDate: '31 Dec 2026',
      ),
    ];
  }
}
