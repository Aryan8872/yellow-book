import 'package:dartz/dartz.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/offer/domain/entity/redemption_entity.dart';

abstract class RedemptionRepository {
  /// Initialise a redemption session for [offerId].
  /// Returns a [RedemptionEntity] with the redemption code that the staff
  /// will scan / verify.
  Future<Either<Failure, RedemptionEntity>> initRedemption(
    String offerId, {
    String? branchId,
  });

  /// Fetch the authenticated user's redemption history.
  /// Optionally filter by [offerId] to get redemptions for a specific offer.
  Future<Either<Failure, List<RedemptionEntity>>> getMyRedemptions({
    String? offerId,
  });

  /// Cancel a redemption session by [sessionId].
  /// Only allowed for INIT or PENDING_SYNC sessions owned by the user.
  Future<Either<Failure, void>> cancelRedemption(String sessionId);
}
