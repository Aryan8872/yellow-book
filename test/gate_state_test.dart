import 'package:entertainer/features/offer/data/model/redemption_model.dart';
import 'package:entertainer/features/offer/domain/gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('deriveGateState', () {
    test('returns none when redemptions list is empty', () {
      final result = deriveGateState([]);
      expect(result, GateState.none);
    });

    test('returns live for INIT session with future expiresAt', () {
      final now = DateTime.now();
      final future = now.add(const Duration(hours: 1));
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'INIT',
          redeemedAt: now,
          expiresAt: future,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.live);
    });

    test('returns none for INIT session with past expiresAt (expired)', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(hours: 1));
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'INIT',
          redeemedAt: now,
          expiresAt: past,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.none);
    });

    test('returns live for PENDING_SYNC session', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'PENDING_SYNC',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.live);
    });

    test('returns redeemed for REDEEMED session', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'REDEEMED',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.redeemed);
    });

    test('returns none for EXPIRED session', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'EXPIRED',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.none);
    });

    test('returns none for REJECTED session', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'REJECTED',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.none);
    });

    test('redeemed wins over live when both present', () {
      final now = DateTime.now();
      final future = now.add(const Duration(hours: 1));
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'REDEEMED',
          redeemedAt: now,
          expiresAt: null,
        ),
        RedemptionModel(
          id: '2',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'INIT',
          redeemedAt: now,
          expiresAt: future,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.redeemed);
    });

    test('ignores malformed/unknown status strings', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'UNKNOWN_STATUS',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.none);
    });

    test('returns live when PENDING_SYNC present with other statuses', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'PENDING_SYNC',
          redeemedAt: now,
          expiresAt: null,
        ),
        RedemptionModel(
          id: '2',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'EXPIRED',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.live);
    });

    test('returns none when only expired and rejected sessions present', () {
      final now = DateTime.now();
      final redemptions = [
        RedemptionModel(
          id: '1',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'EXPIRED',
          redeemedAt: now,
          expiresAt: null,
        ),
        RedemptionModel(
          id: '2',
          offerId: 'offer1',
          offerTitle: 'Test Offer',
          status: 'REJECTED',
          redeemedAt: now,
          expiresAt: null,
        ),
      ];
      final result = deriveGateState(redemptions);
      expect(result, GateState.none);
    });
  });
}
