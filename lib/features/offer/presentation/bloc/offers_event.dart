sealed class OffersEvent {
  const OffersEvent();
}

final class FetchOffersRequested extends OffersEvent {
  final String? q;
  final String? category;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? location;
  final String? sortBy;
  final int page;
  final int limit;
  final bool refresh;

  const FetchOffersRequested({
    this.q,
    this.category,
    this.lat,
    this.lng,
    this.radiusKm,
    this.location,
    this.sortBy,
    this.page = 1,
    this.limit = 20,
    this.refresh = false,
  });
}

final class LoadMoreOffersRequested extends OffersEvent {
  const LoadMoreOffersRequested();
}

final class OfferSearchQueryChanged extends OffersEvent {
  final String query;
  const OfferSearchQueryChanged(this.query);
}

final class OfferCategoryFilterChanged extends OffersEvent {
  final String? category;
  const OfferCategoryFilterChanged(this.category);
}

final class FetchOfferDetailRequested extends OffersEvent {
  final String id;
  const FetchOfferDetailRequested(this.id);
}
