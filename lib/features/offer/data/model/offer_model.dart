import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

class OfferModel {
  final String? id;
  final String title;
  final String description;
  final String terms;
  final OfferCategory category;
  final String? merchantId;
  final String? merchantName;
  final int estimatedSavingsNpr;
  final int maxPerUser;
  final bool isFeatured;
  final bool isActive;
  final Map<String, dynamic>? availabilityJson;
  final DateTime? validFrom;
  final DateTime? validUntil;

  const OfferModel({
    this.id,
    required this.title,
    required this.description,
    required this.terms,
    required this.category,
    this.merchantId,
    this.merchantName,
    this.estimatedSavingsNpr = 0,
    this.maxPerUser = 1,
    this.isFeatured = false,
    this.isActive = true,
    this.availabilityJson,
    this.validFrom,
    this.validUntil,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final merchantMap = json['merchant'] is Map<String, dynamic>
        ? json['merchant'] as Map<String, dynamic>
        : null;

    return OfferModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      terms: json['terms']?.toString() ?? '',
      category: OfferCategory.fromString(json['category']?.toString()),
      merchantId: json['merchantId']?.toString() ?? merchantMap?['id']?.toString(),
      merchantName: json['merchantName']?.toString() ?? merchantMap?['name']?.toString(),
      estimatedSavingsNpr: (json['estimatedSavingsNpr'] as num?)?.toInt() ?? 0,
      maxPerUser: (json['maxPerUser'] as num?)?.toInt() ?? 1,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      availabilityJson: json['availabilityJson'] is Map<String, dynamic>
          ? json['availabilityJson'] as Map<String, dynamic>
          : null,
      validFrom: json['validFrom'] != null ? DateTime.tryParse(json['validFrom'].toString()) : null,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'terms': terms,
      'category': category.name,
      'estimatedSavingsNpr': estimatedSavingsNpr,
      'maxPerUser': maxPerUser,
      'isFeatured': isFeatured,
      'isActive': isActive,
    };
    if (id != null) map['id'] = id;
    if (merchantId != null) map['merchantId'] = merchantId;
    if (merchantName != null) map['merchantName'] = merchantName;
    if (availabilityJson != null) map['availabilityJson'] = availabilityJson;
    if (validFrom != null) map['validFrom'] = validFrom!.toIso8601String();
    if (validUntil != null) map['validUntil'] = validUntil!.toIso8601String();
    return map;
  }

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      title: title,
      description: description,
      terms: terms,
      category: category,
      merchantId: merchantId,
      merchantName: merchantName,
      estimatedSavingsNpr: estimatedSavingsNpr,
      maxPerUser: maxPerUser,
      isFeatured: isFeatured,
      isActive: isActive,
      availabilityJson: availabilityJson,
      validFrom: validFrom,
      validUntil: validUntil,
    );
  }

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      terms: entity.terms,
      category: entity.category,
      merchantId: entity.merchantId,
      merchantName: entity.merchantName,
      estimatedSavingsNpr: entity.estimatedSavingsNpr,
      maxPerUser: entity.maxPerUser,
      isFeatured: entity.isFeatured,
      isActive: entity.isActive,
      availabilityJson: entity.availabilityJson,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
    );
  }
}
