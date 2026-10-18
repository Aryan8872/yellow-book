import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

sealed class OffersState {
  const OffersState();
}

final class OffersInitial extends OffersState {
  const OffersInitial();
}

final class OffersLoading extends OffersState {
  const OffersLoading();
}

final class OffersLoaded extends OffersState {
  final List<OfferEntity> offers;
  final int page;
  final int total;
  final int count;
  final bool hasMore;
  final bool isLoadingMore;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedLocation;

  const OffersLoaded({
    required this.offers,
    required this.page,
    required this.total,
    required this.count,
    required this.hasMore,
    this.isLoadingMore = false,
    this.searchQuery,
    this.selectedCategory,
    this.selectedLocation,
  });

  OffersLoaded copyWith({
    List<OfferEntity>? offers,
    int? page,
    int? total,
    int? count,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? selectedCategory,
    String? selectedLocation,
  }) {
    return OffersLoaded(
      offers: offers ?? this.offers,
      page: page ?? this.page,
      total: total ?? this.total,
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

final class OffersError extends OffersState {
  final String message;
  const OffersError(this.message);
}

final class OfferDetailLoading extends OffersState {
  const OfferDetailLoading();
}

final class OfferDetailLoaded extends OffersState {
  final OfferEntity offer;
  const OfferDetailLoaded(this.offer);
}

final class OfferDetailError extends OffersState {
  final String message;
  const OfferDetailError(this.message);
}
