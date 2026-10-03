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

class OfferEntity {
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

  const OfferEntity({
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
