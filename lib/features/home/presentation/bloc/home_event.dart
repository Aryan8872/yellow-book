import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Fired when a user taps any offer card — carries the full entity.
final class OfferCardSelected extends HomeEvent {
  final OfferEntity offer;
  const OfferCardSelected(this.offer);
}

final class CategorySelected extends HomeEvent {
  final String categoryName;
  const CategorySelected(this.categoryName);
}
