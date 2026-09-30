class OfferEntity {
  final String id;
  final String merchantName;
  final String title;
  final String description;
  final String category;
  final String location;
  final String distance;
  final String highlightTag;
  final String imageUrl;
  final String expiryDate;
  final int redemptionsRemaining;

  const OfferEntity({
    required this.id,
    required this.merchantName,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.distance,
    required this.highlightTag,
    required this.imageUrl,
    required this.expiryDate,
    this.redemptionsRemaining = 3,
  });

  Map<String, String> toMap() {
    return {
      'id': id,
      'hotelName': merchantName,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'distanceFromUser': distance,
      'highlightTag': highlightTag,
      'image': imageUrl,
      'expiryDate': expiryDate,
      'redemptionsRemaining': redemptionsRemaining.toString(),
    };
  }
}
