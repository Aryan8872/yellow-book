import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';

/// Data transfer object for a single redemption from the backend.
/// Parses the enriched GET /redemptions/me payload (flat keys + nested
/// offer/merchant/branch), staying nullable-safe for legacy flat-only shapes.
class RedemptionModel {
  final String id;
  final String offerId;
  final String offerTitle;
  final String? merchantName;
  final String status;
  final String? redemptionCode;
  final String? qrPayload;
  final DateTime redeemedAt;
  final DateTime? expiresAt;
  final num? savingsNpr;

  final RedemptionOfferInfo? offer;
  final RedemptionMerchantInfo? merchant;
  final RedemptionBranchInfo? branch;

  const RedemptionModel({
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

  /// Accepts num or numeric-string lat/lng (Prisma Decimal serializes to string).
  static double? _toDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static RedemptionBranchInfo? _branchFromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final name = map['name']?.toString();
    if (name == null || name.isEmpty) return null;
    return RedemptionBranchInfo(
      id: map['id']?.toString(),
      name: name,
      address: map['address']?.toString(),
      district: map['district']?.toString(),
      lat: _toDouble(map['lat']),
      lng: _toDouble(map['lng']),
    );
  }

  static RedemptionMerchantInfo? _merchantFromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id']?.toString();
    final name = map['name']?.toString();
    if ((id == null || id.isEmpty) && (name == null || name.isEmpty)) {
      return null;
    }
    final branches = map['branches'];
    return RedemptionMerchantInfo(
      id: id ?? '',
      name: name ?? '',
      logoUrl: map['logoUrl']?.toString(),
      branches: branches is List
          ? branches
              .map(_branchFromJson)
              .whereType<RedemptionBranchInfo>()
              .toList()
          : const [],
    );
  }

  static RedemptionOfferInfo? _offerFromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final category = map['category'] is Map
        ? Map<String, dynamic>.from(map['category'] as Map)
        : null;
    return RedemptionOfferInfo(
      description: map['description']?.toString(),
      terms: map['terms']?.toString(),
      coverImage: map['coverImage']?.toString(),
      estimatedSavingsNpr: map['estimatedSavingsNpr'] is num
          ? map['estimatedSavingsNpr'] as num
          : null,
      originalPriceNpr: map['originalPriceNpr'] is num
          ? map['originalPriceNpr'] as num
          : null,
      discountPercentage: map['discountPercentage'] is num
          ? map['discountPercentage'] as num
          : null,
      categoryName: category?['name']?.toString(),
    );
  }

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    // Unwrap nested offer/merchant/branch when the response is enriched.
    final offerMap = json['offer'] is Map
        ? Map<String, dynamic>.from(json['offer'] as Map)
        : null;

    // Enriched payload carries merchant at the top level; older shapes nest
    // it inside the offer map — accept both.
    Object? merchantRaw =
        json['merchant'] ?? (offerMap == null ? null : offerMap['merchant']);

    final branchRaw = json['branch'];

    final merchant = _merchantFromJson(merchantRaw);

    return RedemptionModel(
      id: json['id']?.toString() ?? '',
      offerId: json['offerId']?.toString() ??
          offerMap?['id']?.toString() ??
          '',
      offerTitle: json['offerTitle']?.toString() ??
          offerMap?['title']?.toString() ??
          '',
      merchantName: json['merchantName']?.toString() ?? merchant?.name,
      status: json['status']?.toString() ?? 'INIT',
      redemptionCode: json['redemptionCode']?.toString() ??
          json['code']?.toString(),
      qrPayload: json['qrPayload']?.toString(),
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      savingsNpr:
          json['savingsNpr'] is num ? json['savingsNpr'] as num : null,
      offer: offerMap == null ? null : _offerFromJson(offerMap),
      merchant: merchant,
      branch: _branchFromJson(branchRaw),
    );
  }

  RedemptionEntity toEntity() => RedemptionEntity(
        id: id,
        offerId: offerId,
        offerTitle: offerTitle,
        merchantName: merchantName,
        status: status,
        redemptionCode: redemptionCode,
        qrPayload: qrPayload,
        redeemedAt: redeemedAt,
        expiresAt: expiresAt,
        savingsNpr: savingsNpr,
        offer: offer,
        merchant: merchant,
        branch: branch,
      );
}
