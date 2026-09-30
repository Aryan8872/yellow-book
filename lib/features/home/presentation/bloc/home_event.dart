sealed class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class TrendingOfferSelected extends HomeEvent {
  final Map<String, String> offer;
  const TrendingOfferSelected(this.offer);
}

final class CategorySelected extends HomeEvent {
  final String categoryName;
  const CategorySelected(this.categoryName);
}
