/// Redemption domain entity — what the consumer-facing app cares about.
class RedemptionEntity {
  final String id;
  final String offerId;
  final String offerTitle;
  final String? merchantName;
  final String status; // canonical backend union: INIT | PENDING_SYNC | REDEEMED | REJECTED | EXPIRED
  final String? redemptionCode;
  final String? qrPayload;
  final DateTime redeemedAt;
  final DateTime? expiresAt;

  /// Value saved in NPR for REDEEMED sessions (flat legacy key, now surfaced).
  final num? savingsNpr;

  /// Enriched offer payload from GET /redemptions/me (RED-03) — null when the
  /// backend has not enriched the shape yet.
  final RedemptionOfferInfo? offer;

  /// Enriched merchant payload — null on legacy/unenriched responses.
  final RedemptionMerchantInfo? merchant;

  /// Resolved branch for the session; server falls back to the merchant's
  /// first active branch, so this is null only when the merchant has none.
  final RedemptionBranchInfo? branch;

  const RedemptionEntity({
    required this.id,
    required this.offerId,
    required this.offerTitle,
    this.merchantName,
    required this.status,
    this.redemptionCode,
    this.qrPayload,
    required this.redeemedAt,
    this.expiresAt,
    this.savingsNpr,
    this.offer,
    this.merchant,
    this.branch,
  });

  bool get isActive =>
      status == 'PENDING' &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  /// Generates the standard OfferNepal QR payload if the backend did not provide one directly.
  /// Format matches the backend generator: `offernepal://redeem?code=CODE`
  String get computedQrPayload {
    if (qrPayload != null && qrPayload!.trim().isNotEmpty) {
      return qrPayload!.trim();
    }
    final code = redemptionCode ?? (id.isNotEmpty ? id.substring(0, 8).toUpperCase() : '');
    return 'offernepal://redeem?code=$code';
  }

  /// Convert entity to JSON map for navigation. Keeps the legacy `sessionId`
  /// key for compatibility with existing consumers (E3) and now also carries
  /// the enriched nested payloads when present.
  Map<String, dynamic> toJson() {
    return {
      'sessionId': id,
      'id': id,
      'offerId': offerId,
      'offer': {
        'id': offerId,
        'title': offerTitle,
        if (offer != null) ...{
          'description': offer!.description,
          'terms': offer!.terms,
          'coverImage': offer!.coverImage,
          'estimatedSavingsNpr': offer!.estimatedSavingsNpr,
          'originalPriceNpr': offer!.originalPriceNpr,
          'discountPercentage': offer!.discountPercentage,
          'categoryName': offer!.categoryName,
        },
      },
      'merchant': {
        'name': merchantName,
        if (merchant != null) ...{
          'id': merchant!.id,
          'logoUrl': merchant!.logoUrl,
          'branches': merchant!.branches
              .map((b) => b.toJson())
              .toList(),
        },
      },
      if (branch != null) 'branch': branch!.toJson(),
      'status': status,
      'code': redemptionCode,
      'qrPayload': qrPayload ?? computedQrPayload,
      'savingsNpr': savingsNpr,
      'redeemedAt': redeemedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

/// Enriched offer details attached to a redemption (RED-03).
class RedemptionOfferInfo {
  final String? description;
  final String? terms;
  final String? coverImage;
  final num? estimatedSavingsNpr;
  final num? originalPriceNpr;
  final num? discountPercentage;
  final String? categoryName;

  const RedemptionOfferInfo({
    this.description,
    this.terms,
    this.coverImage,
    this.estimatedSavingsNpr,
    this.originalPriceNpr,
    this.discountPercentage,
    this.categoryName,
  });
}

/// Enriched merchant details attached to a redemption (RDS-02).
class RedemptionMerchantInfo {
  final String id;
  final String name;
  final String? logoUrl;
  final List<RedemptionBranchInfo> branches;

  const RedemptionMerchantInfo({
    required this.id,
    required this.name,
    this.logoUrl,
    this.branches = const [],
  });
}

/// Branch brief consumed by the redemption history / map flow.
/// lat/lng arrive as numbers from the enriched payload (Decimal-safe).
class RedemptionBranchInfo {
  final String? id;
  final String name;
  final String? address;
  final String? district;
  final double? lat;
  final double? lng;

  const RedemptionBranchInfo({
    this.id,
    required this.name,
    this.address,
    this.district,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (address != null) 'address': address,
        if (district != null) 'district': district,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}
