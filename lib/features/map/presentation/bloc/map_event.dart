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

final class MapFocusBranchRequested extends MapEvent {
  final double lat;
  final double lng;
  final String? title;
  const MapFocusBranchRequested({
    required this.lat,
    required this.lng,
    this.title,
  });
}

final class MapErrorOccurred extends MapEvent {
  final String message;
  final String? details;
  const MapErrorOccurred(this.message, [this.details]);
}
