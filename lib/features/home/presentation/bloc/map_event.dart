sealed class MapEvent {
  const MapEvent();
}

final class MapInitialLoadRequested extends MapEvent {
  const MapInitialLoadRequested();
}

final class MapQueryChanged extends MapEvent {
  final String query;
  const MapQueryChanged(this.query);
}

final class MapCategoryChanged extends MapEvent {
  final String category;
  const MapCategoryChanged(this.category);
}

final class MapMerchantSelected extends MapEvent {
  final Map<String, dynamic> merchant;
  const MapMerchantSelected(this.merchant);
}

final class MapCardDismissed extends MapEvent {
  const MapCardDismissed();
}

final class MapRecenterRequested extends MapEvent {
  const MapRecenterRequested();
}
