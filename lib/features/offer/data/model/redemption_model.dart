import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';

/// Data transfer object for a single redemption from the backend.
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
  });

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    // Unwrap nested offer/merchant if present
    final offerMap = json['offer'] is Map
        ? Map<String, dynamic>.from(json['offer'] as Map)
        : null;

    final merchantMap = offerMap?['merchant'] is Map
        ? Map<String, dynamic>.from(offerMap!['merchant'] as Map)
        : null;

    return RedemptionModel(
      id: json['id']?.toString() ?? '',
      offerId: json['offerId']?.toString() ??
          offerMap?['id']?.toString() ??
          '',
      offerTitle: json['offerTitle']?.toString() ??
          offerMap?['title']?.toString() ??
          '',
      merchantName: json['merchantName']?.toString() ??
          merchantMap?['name']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      redemptionCode: json['redemptionCode']?.toString() ??
          json['code']?.toString(),
      qrPayload: json['qrPayload']?.toString(),
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
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
      );
}
