sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded();
}

final class NavigateToOfferDetail extends HomeState {
  final Map<String, String> offer;
  const NavigateToOfferDetail(this.offer);
}

final class NavigateToCategoryOffers extends HomeState {
  final String categoryName;
  const NavigateToCategoryOffers(this.categoryName);
}
