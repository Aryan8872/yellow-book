import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

class GetOfferByIdParams {
  final String id;
  const GetOfferByIdParams({required this.id});
}

class GetPaginatedOffersParams {
  final int page;
  final int limit;
  final String? q;
  final String? category;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? merchantId;
  final bool? isFeatured;
  final String? sortBy; // 'trending', 'popular', 'rating', 'savings', 'newest'
  final String? location; // location/city filter for the backend
  final Map<String, dynamic>? additionalQuery;

  const GetPaginatedOffersParams({
    this.page = 1,
    this.limit = 20,
    this.q,
    this.category,
    this.lat,
    this.lng,
    this.radiusKm,
    this.merchantId,
    this.isFeatured,
    this.sortBy,
    this.location,
    this.additionalQuery,
  });

  Map<String, dynamic> toQueryParameters() {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (q != null && q!.trim().isNotEmpty) query['q'] = q!.trim();
    if (category != null && category!.trim().isNotEmpty) query['category'] = category!.trim();
    if (lat != null) query['lat'] = lat;
    if (lng != null) query['lng'] = lng;
    if (radiusKm != null) query['radiusKm'] = radiusKm;
    if (merchantId != null && merchantId!.isNotEmpty) query['merchantId'] = merchantId;
    if (isFeatured != null) query['isFeatured'] = isFeatured;
    if (sortBy != null && sortBy!.trim().isNotEmpty) query['sortBy'] = sortBy!.trim();
    if (location != null && location!.trim().isNotEmpty) query['location'] = location!.trim();
    if (additionalQuery != null) query.addAll(additionalQuery!);
    return query;
  }
}

class CreateOfferParams {
  final String title;
  final String description;
  final String terms;
  final OfferCategory category;
  final String? merchantId;
  final int estimatedSavingsNpr;
  final int maxPerUser;
  final bool isFeatured;
  final Map<String, dynamic>? availabilityJson;
  final DateTime? validFrom;
  final DateTime? validUntil;

  const CreateOfferParams({
    required this.title,
    required this.description,
    required this.terms,
    required this.category,
    this.merchantId,
    this.estimatedSavingsNpr = 0,
    this.maxPerUser = 1,
    this.isFeatured = false,
    this.availabilityJson,
    this.validFrom,
    this.validUntil,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'terms': terms,
      'category': category.name,
      'estimatedSavingsNpr': estimatedSavingsNpr,
      'maxPerUser': maxPerUser,
      'isFeatured': isFeatured,
    };
    if (merchantId != null && merchantId!.isNotEmpty) map['merchantId'] = merchantId;
    if (availabilityJson != null) map['availabilityJson'] = availabilityJson;
    if (validFrom != null) map['validFrom'] = validFrom!.toIso8601String();
    if (validUntil != null) map['validUntil'] = validUntil!.toIso8601String();
    return map;
  }
}

class UpdateOfferParams {
  final String offerId;
  final String? merchantId;
  final String? title;
  final String? description;
  final String? terms;
  final OfferCategory? category;
  final int? estimatedSavingsNpr;
  final int? maxPerUser;
  final bool? isFeatured;
  final bool? isActive;
  final Map<String, dynamic>? availabilityJson;
  final DateTime? validFrom;
  final DateTime? validUntil;

  const UpdateOfferParams({
    required this.offerId,
    this.merchantId,
    this.title,
    this.description,
    this.terms,
    this.category,
    this.estimatedSavingsNpr,
    this.maxPerUser,
    this.isFeatured,
    this.isActive,
    this.availabilityJson,
    this.validFrom,
    this.validUntil,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (terms != null) map['terms'] = terms;
    if (category != null) map['category'] = category!.name;
    if (estimatedSavingsNpr != null) map['estimatedSavingsNpr'] = estimatedSavingsNpr;
    if (maxPerUser != null) map['maxPerUser'] = maxPerUser;
    if (isFeatured != null) map['isFeatured'] = isFeatured;
    if (isActive != null) map['isActive'] = isActive;
    if (availabilityJson != null) map['availabilityJson'] = availabilityJson;
    if (validFrom != null) map['validFrom'] = validFrom!.toIso8601String();
    if (validUntil != null) map['validUntil'] = validUntil!.toIso8601String();
    return map;
  }
}

class DeleteOfferParams {
  final String offerId;
  final String? merchantId;

  const DeleteOfferParams({
    required this.offerId,
    this.merchantId,
  });
}
