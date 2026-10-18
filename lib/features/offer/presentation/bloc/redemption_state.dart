import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';

sealed class RedemptionState {
  const RedemptionState();
}

final class RedemptionInitial extends RedemptionState {
  const RedemptionInitial();
}

final class RedemptionLoading extends RedemptionState {
  const RedemptionLoading();
}

/// Redemption initiated — holds the live code for QR/display.
final class RedemptionSuccess extends RedemptionState {
  final RedemptionEntity redemption;
  const RedemptionSuccess(this.redemption);
}

final class RedemptionError extends RedemptionState {
  final String message;
  const RedemptionError(this.message);
}

/// History loaded state
final class RedemptionHistoryLoaded extends RedemptionState {
  final List<RedemptionEntity> redemptions;
  const RedemptionHistoryLoaded(this.redemptions);
}
