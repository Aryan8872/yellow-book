import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

class MerchantBranchModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;

  const MerchantBranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });

  factory MerchantBranchModel.fromJson(Map<String, dynamic> json) {
    return MerchantBranchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'city': city,
    'lat': lat,
    'lng': lng,
  };

  MerchantBranchEntity toEntity() => MerchantBranchEntity(
    id: id,
    name: name,
    address: address,
    city: city,
    lat: lat,
    lng: lng,
  );
}

class MerchantDetailModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? websiteUrl;
  final String? contactEmail;
  final String? contactPhone;
  final List<MerchantBranchModel> branches;

  const MerchantDetailModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.websiteUrl,
    this.contactEmail,
    this.contactPhone,
    this.branches = const [],
  });

  factory MerchantDetailModel.fromJson(Map<String, dynamic> json) {
    final rawBranches = json['branches'] as List<dynamic>? ?? [];
    return MerchantDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      websiteUrl: json['websiteUrl']?.toString(),
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      branches: rawBranches
          .whereType<Map<String, dynamic>>()
          .map((b) => MerchantBranchModel.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'logoUrl': logoUrl,
    'coverUrl': coverUrl,
    'websiteUrl': websiteUrl,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
    'branches': branches.map((b) => b.toJson()).toList(),
  };

  MerchantDetailEntity toEntity() => MerchantDetailEntity(
    id: id,
    name: name,
    description: description,
    logoUrl: logoUrl,
    coverUrl: coverUrl,
    websiteUrl: websiteUrl,
    contactEmail: contactEmail,
    contactPhone: contactPhone,
    branches: branches.map((b) => b.toEntity()).toList(),
  );
}

class OfferModel {
  final String? id;
  final String title;
  final String description;
  final String terms;
  final String? categoryId;
  final String? categoryName;
  final String? merchantId;
  final String? merchantName;
  final int estimatedSavingsNpr;
  final int? originalPriceNpr;
  final int? discountedPriceNpr;
  final int? discountPercentage;
  final String? imageUrl;
  final List<String> images;
  final List<String> highlights;
  final double rating;
  final int reviewsCount;
  final int maxPerUser;
  final bool isFeatured;
  final bool isActive;
  final Map<String, dynamic>? availabilityJson;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final MerchantDetailModel? merchant;
  final List<MerchantBranchModel> branches;

  const OfferModel({
    this.id,
    required this.title,
    required this.description,
    required this.terms,
    this.categoryId,
    this.categoryName,
    this.merchantId,
    this.merchantName,
    this.estimatedSavingsNpr = 0,
    this.originalPriceNpr,
    this.discountedPriceNpr,
    this.discountPercentage,
    this.imageUrl,
    this.images = const [],
    this.highlights = const [],
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.maxPerUser = 1,
    this.isFeatured = false,
    this.isActive = true,
    this.availabilityJson,
    this.validFrom,
    this.validUntil,
    this.merchant,
    this.branches = const [],
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final merchantMap = json['merchant'] is Map<String, dynamic>
        ? json['merchant'] as Map<String, dynamic>
        : null;

    final categoryMap = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : null;

    final rawImages = json['images'] as List<dynamic>?;
    final List<String> parsedImages = rawImages != null
        ? rawImages.map((e) => e.toString()).toList()
        : [];

    final rawHighlights = json['highlights'] as List<dynamic>?;
    final List<String> parsedHighlights = rawHighlights != null
        ? rawHighlights.map((e) => e.toString()).toList()
        : [];

    final rawBranches = json['branches'] as List<dynamic>?;
    final List<MerchantBranchModel> parsedBranches = rawBranches != null
        ? rawBranches
            .whereType<Map<String, dynamic>>()
            .map((b) => MerchantBranchModel.fromJson(b))
            .toList()
        : [];

    return OfferModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      terms: json['terms']?.toString() ?? '',
      categoryId:
          json['categoryId']?.toString() ?? categoryMap?['id']?.toString(),
      categoryName:
          json['categoryName']?.toString() ?? categoryMap?['name']?.toString(),
      merchantId:
          json['merchantId']?.toString() ?? merchantMap?['id']?.toString(),
      merchantName:
          json['merchantName']?.toString() ?? merchantMap?['name']?.toString(),
      estimatedSavingsNpr: (json['estimatedSavingsNpr'] as num?)?.toInt() ?? 0,
      originalPriceNpr: (json['originalPriceNpr'] as num?)?.toInt(),
      discountedPriceNpr: (json['discountedPriceNpr'] as num?)?.toInt(),
      discountPercentage: (json['discountPercentage'] as num?)?.toInt(),
      imageUrl:
          json['imageUrl']?.toString() ??
          (parsedImages.isNotEmpty ? parsedImages.first : null),
      images: parsedImages,
      highlights: parsedHighlights,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      maxPerUser: (json['maxPerUser'] as num?)?.toInt() ?? 1,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      availabilityJson: json['availabilityJson'] is Map<String, dynamic>
          ? json['availabilityJson'] as Map<String, dynamic>
          : null,
      validFrom: json['validFrom'] != null
          ? DateTime.tryParse(json['validFrom'].toString())
          : null,
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'].toString())
          : null,
      merchant: merchantMap != null
          ? MerchantDetailModel.fromJson(merchantMap)
          : null,
      branches: parsedBranches,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'terms': terms,
      'estimatedSavingsNpr': estimatedSavingsNpr,
      'originalPriceNpr': originalPriceNpr,
      'discountedPriceNpr': discountedPriceNpr,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'images': images,
      'highlights': highlights,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'maxPerUser': maxPerUser,
      'isFeatured': isFeatured,
      'isActive': isActive,
    };
    if (id != null) map['id'] = id;
    if (categoryId != null) map['categoryId'] = categoryId;
    if (merchantId != null) map['merchantId'] = merchantId;
    if (merchantName != null) map['merchantName'] = merchantName;
    if (availabilityJson != null) map['availabilityJson'] = availabilityJson;
    if (validFrom != null) map['validFrom'] = validFrom!.toIso8601String();
    if (validUntil != null) map['validUntil'] = validUntil!.toIso8601String();
    if (merchant != null) map['merchant'] = merchant!.toJson();
    return map;
  }

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      title: title,
      description: description,
      terms: terms,
      category: categoryName != null
          ? OfferCategory.fromString(categoryName!)
          : OfferCategory.dining,
      categoryId: categoryId,
      merchantId: merchantId,
      merchantName: merchantName,
      estimatedSavingsNpr: estimatedSavingsNpr,
      originalPriceNpr: originalPriceNpr,
      discountedPriceNpr: discountedPriceNpr,
      discountPercentage: discountPercentage,
      imageUrl: imageUrl,
      images: images,
      highlights: highlights,
      rating: rating,
      reviewsCount: reviewsCount,
      maxPerUser: maxPerUser,
      isFeatured: isFeatured,
      isActive: isActive,
      availabilityJson: availabilityJson,
      validFrom: validFrom,
      validUntil: validUntil,
      merchant: merchant?.toEntity(),
      branches: branches.map((b) => b.toEntity()).toList(),
    );
  }

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      terms: entity.terms,
      categoryName: entity.category.name,
      merchantId: entity.merchantId,
      merchantName: entity.merchantName,
      estimatedSavingsNpr: entity.estimatedSavingsNpr,
      originalPriceNpr: entity.originalPriceNpr,
      discountedPriceNpr: entity.discountedPriceNpr,
      discountPercentage: entity.discountPercentage,
      imageUrl: entity.imageUrl,
      images: entity.images,
      highlights: entity.highlights,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      maxPerUser: entity.maxPerUser,
      isFeatured: entity.isFeatured,
      isActive: entity.isActive,
      availabilityJson: entity.availabilityJson,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
    );
  }
}
