import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  // Rich mock pool of premier discount offers
  static final List<Map<String, String>> _allMockOffers = [
    {
      "hotelName": "Tribes Restaurant",
      "distanceFromUser": "1.2 km away",
      "highlightTag": "BOGOF",
      "location": "The Dubai Mall",
      "category": "Dining",
      "rating": "4.9",
      "offerType": "Buy 1 Get 1 Main Course",
      "image": "https://img.magnific.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80",
    },
    {
      "hotelName": "Green Bowl Organic Salads",
      "distanceFromUser": "2.5 km away",
      "highlightTag": "Healthy",
      "location": "Kathmandu Valley",
      "category": "Dining",
      "rating": "4.8",
      "offerType": "Buy 1 Get 1 Salad Bowl",
      "image": "https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/01/12/12/healthy-avo-food.jpg",
    },
    {
      "hotelName": "Spicy Hub Tandoori",
      "distanceFromUser": "3.1 km away",
      "highlightTag": "Local",
      "location": "Lalitpur Central",
      "category": "Dining",
      "rating": "4.6",
      "offerType": "Buy 1 Get 1 Biryani",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-GyDbcO4oFC8rngIjIlp4oHrvISS-xUkIpj5TUFqB9PYhco-8q06vFkAy&s=10",
    },
    {
      "hotelName": "Urban Bites Street Feast",
      "distanceFromUser": "4.0 km away",
      "highlightTag": "Street Food",
      "location": "Bhaktapur Gate",
      "category": "Dining",
      "rating": "4.7",
      "offerType": "Buy 1 Get 1 Burger Combo",
      "image": "https://img.etimg.com/thumb/width-1200,height-1200,imgsize-1566631,resizemode-75,msid-128680152/news/new-updates/street-food-without-the-guilt-famous-cardiologist-shares-5-tasty-picks-that-are-healthy-and-easy-on-your-pocket.jpg",
    },
    {
      "hotelName": "Himalayan Java Coffee",
      "distanceFromUser": "0.8 km away",
      "highlightTag": "Coffee",
      "location": "Durbar Marg",
      "category": "Offers",
      "rating": "4.9",
      "offerType": "Buy 1 Get 1 Espresso Drink",
      "image": "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=600&q=80",
    },
    {
      "hotelName": "Serene Valley Spa & Wellness",
      "distanceFromUser": "2.8 km away",
      "highlightTag": "Spa",
      "location": "Lakeside Resort",
      "category": "Activities",
      "rating": "4.9",
      "offerType": "Buy 1 Get 1 Full Body Massage",
      "image": "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80",
    },
    {
      "hotelName": "Grand Horizon Luxury Hotel",
      "distanceFromUser": "5.0 km away",
      "highlightTag": "Staycation",
      "location": "Hilltop View",
      "category": "Hotels",
      "rating": "4.9",
      "offerType": "Buy 1 Night Get 1 Night Free",
      "image": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80",
    },
  ];

  String _currentQuery = '';
  String _activeCategory = 'All';

  SearchBloc()
      : super(SearchSuccessState(
          query: '',
          activeCategory: 'All',
          results: _allMockOffers,
        )) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCategoryFilterApplied>(_onSearchCategoryFilterApplied);
    on<SearchCleared>(_onSearchCleared);
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    _currentQuery = event.query.trim().toLowerCase();
    _filterAndEmit(emit);
  }

  void _onSearchCategoryFilterApplied(SearchCategoryFilterApplied event, Emitter<SearchState> emit) {
    _activeCategory = event.category;
    _filterAndEmit(emit);
  }

  void _onSearchCleared(SearchCleared event, Emitter<SearchState> emit) {
    _currentQuery = '';
    _activeCategory = 'All';
    _filterAndEmit(emit);
  }

  void _filterAndEmit(Emitter<SearchState> emit) {
    // Client-presentable instant search algorithm:
    // Even if client types random words, we dynamically match or fallback to top rated trending offers
    final matched = _allMockOffers.where((item) {
      final nameMatches = item["hotelName"]!.toLowerCase().contains(_currentQuery);
      final locationMatches = item["location"]!.toLowerCase().contains(_currentQuery);
      final tagMatches = item["highlightTag"]!.toLowerCase().contains(_currentQuery);
      final categoryMatches = _activeCategory == 'All' || item["category"] == _activeCategory;

      if (_currentQuery.isEmpty) {
        return categoryMatches;
      }
      return (nameMatches || locationMatches || tagMatches) && categoryMatches;
    }).toList();

    // If query has no direct substring match (e.g. user typed random letters like 'asdfg'),
    // we still provide a client-ready recommended set of verified BOGOF deals!
    final finalResults = matched.isNotEmpty ? matched : _allMockOffers;

    emit(SearchSuccessState(
      query: _currentQuery,
      activeCategory: _activeCategory,
      results: finalResults,
    ));
  }
}
