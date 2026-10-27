enum OfferCategory {
  dining,
  wellness,
  entertainment,
  retail,
  travel,
  beauty;

  factory OfferCategory.fromString(String? value) {
    if (value == null || value.trim().isEmpty) return OfferCategory.dining;
    final normalized = value.trim().toUpperCase();
    return OfferCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == normalized,
      orElse: () => OfferCategory.dining,
    );
  }

  String toJson() => name.toUpperCase();
}

class MerchantBranchEntity {
  final String id;
  final String name;
  final String address;
  final String city;
  final double lat;
  final double lng;

  const MerchantBranchEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
  });
}

class MerchantDetailEntity {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? websiteUrl;
  final String? contactEmail;
  final String? contactPhone;
  final List<MerchantBranchEntity> branches;

  const MerchantDetailEntity({
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
}

class OfferEntity {
  final String? id;
  final String title;
  final String description;
  final String terms;
  final OfferCategory category;
  final String? categoryId;
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
  final MerchantDetailEntity? merchant;
  final List<MerchantBranchEntity> branches;

  const OfferEntity({
    this.id,
    required this.title,
    required this.description,
    required this.terms,
    required this.category,
    this.categoryId,
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

  /// Map representation for backward compatibility with old widgets
  Map<String, String> toLegacyMap() {
    final effectiveBranches = branches.isNotEmpty ? branches : (merchant?.branches ?? const []);
    final branch = effectiveBranches.isNotEmpty ? effectiveBranches.first : null;
    return {
      'id': id ?? '',
      'hotelName': merchantName ?? merchant?.name ?? 'Merchant',
      'title': title,
      'description': description,
      'terms': terms,
      'category': category.name,
      'location': branch?.address ?? branch?.city ?? 'Kathmandu, Nepal',
      'distanceFromUser': '1.2 km away',
      'highlightTag': discountPercentage != null && discountPercentage! > 0
          ? '$discountPercentage% OFF'
          : 'BOGOF',
      'image':
          imageUrl ??
          (images.isNotEmpty
              ? images.first
              : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80'),
      'expiryDate': validUntil != null
          ? '${validUntil!.day} ${_monthName(validUntil!.month)} ${validUntil!.year}'
          : '31 Dec 2026',
      'estimatedSavings': 'Save NPR $estimatedSavingsNpr',
      'originalPrice': originalPriceNpr != null ? 'NPR $originalPriceNpr' : '',
      'discountedPrice': discountedPriceNpr != null
          ? 'NPR $discountedPriceNpr'
          : '',
      'rating': rating.toStringAsFixed(1),
      'reviewsCount': reviewsCount.toString(),
    };
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}

class PaginatedOfferEntity {
  final List<OfferEntity> offers;
  final int count;
  final int total;
  final int page;
  final int limit;

  const PaginatedOfferEntity({
    required this.offers,
    required this.count,
    required this.total,
    this.page = 1,
    this.limit = 10,
  });
}
