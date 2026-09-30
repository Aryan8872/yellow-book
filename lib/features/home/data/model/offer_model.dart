import '../../domain/entities/offer_entity.dart';

class OfferModel {
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

  const OfferModel({
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

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String? ?? '',
      merchantName: json['merchantName'] as String? ?? json['hotelName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      distance: json['distance'] as String? ?? json['distanceFromUser'] as String? ?? '',
      highlightTag: json['highlightTag'] as String? ?? 'BOGOF',
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '31 Dec 2026',
      redemptionsRemaining: json['redemptionsRemaining'] as int? ?? 3,
    );
  }

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      merchantName: merchantName,
      title: title,
      description: description,
      category: category,
      location: location,
      distance: distance,
      highlightTag: highlightTag,
      imageUrl: imageUrl,
      expiryDate: expiryDate,
      redemptionsRemaining: redemptionsRemaining,
    );
  }
}
