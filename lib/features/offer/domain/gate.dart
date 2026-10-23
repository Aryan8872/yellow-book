import 'package:entertainer/features/offer/data/model/redemption_model.dart';

enum GateState {
  loading,
  none,
  live,
  redeemed,
  failed,
}

GateState deriveGateState(List<RedemptionModel> redemptions) {
  if (redemptions.isEmpty) {
    return GateState.none;
  }

  // Check for redeemed first (highest precedence)
  final hasRedeemed = redemptions.any((r) => r.status == 'REDEEMED');
  if (hasRedeemed) {
    return GateState.redeemed;
  }

  // Check for live sessions (INIT with future expiresAt or PENDING_SYNC)
  final now = DateTime.now();
  final hasLive = redemptions.any((r) {
    final status = r.status.toUpperCase();
    if (status == 'PENDING_SYNC') {
      return true;
    }
    if (status == 'INIT' && r.expiresAt != null) {
      return r.expiresAt!.isAfter(now);
    }
    return false;
  });

  if (hasLive) {
    return GateState.live;
  }

  // All other cases (EXPIRED, REJECTED, unknown, expired INIT) → none
  return GateState.none;
}
