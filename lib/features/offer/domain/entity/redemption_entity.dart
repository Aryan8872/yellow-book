/// Redemption domain entity — what the consumer-facing app cares about.
class RedemptionEntity {
  final String id;
  final String offerId;
  final String offerTitle;
  final String? merchantName;
  final String status; // 'PENDING' | 'COMPLETED' | 'CANCELLED'
  final String? redemptionCode;
  final String? qrPayload;
  final DateTime redeemedAt;
  final DateTime? expiresAt;

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
}
