sealed class RedemptionEvent {
  const RedemptionEvent();
}

/// Trigger: user taps "Redeem Now" on an offer detail page.
final class InitRedemptionRequested extends RedemptionEvent {
  final String offerId;
  const InitRedemptionRequested(this.offerId);
}

/// Trigger: user opens their redemption history / "My Savings" tab.
final class FetchMyRedemptionsRequested extends RedemptionEvent {
  const FetchMyRedemptionsRequested();
}

/// Trigger: user cancels their own redemption (INIT status only).
final class CancelRedemptionRequested extends RedemptionEvent {
  final String sessionId;
  const CancelRedemptionRequested(this.sessionId);
}

/// Reset back to initial (e.g. on bottom-sheet dismiss).
final class RedemptionReset extends RedemptionEvent {
  const RedemptionReset();
}
