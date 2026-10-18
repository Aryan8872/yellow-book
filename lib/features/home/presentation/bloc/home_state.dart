import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';
import '../../domain/entities/home_feed_data.dart';

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
  final HomeFeedData feedData;
  const HomeLoaded({required this.feedData});
}

final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}

/// Navigation trigger: open the full detail page for this offer.
final class NavigateToOfferDetail extends HomeState {
  final OfferEntity offer;
  const NavigateToOfferDetail(this.offer);
}

final class NavigateToCategoryOffers extends HomeState {
  final String categoryName;
  const NavigateToCategoryOffers(this.categoryName);
}
