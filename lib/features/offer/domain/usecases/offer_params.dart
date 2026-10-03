import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

class GetOfferByIdParams {
  final String id;
  const GetOfferByIdParams({required this.id});
}

class GetPaginatedOffersParams {
  final int page;
  final int limit;
  final String? category;
  final String? merchantId;
  final String? search;
  final bool? isFeatured;
  final Map<String, dynamic>? additionalQuery;

  const GetPaginatedOffersParams({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.merchantId,
    this.search,
    this.isFeatured,
    this.additionalQuery,
  });

  Map<String, dynamic> toQueryParameters() {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null && category!.isNotEmpty) query['category'] = category;
    if (merchantId != null && merchantId!.isNotEmpty) query['merchantId'] = merchantId;
    if (search != null && search!.isNotEmpty) query['search'] = search;
    if (isFeatured != null) query['isFeatured'] = isFeatured;
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
