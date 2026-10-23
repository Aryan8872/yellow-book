import 'package:dartz/dartz.dart';
import 'package:entertainer/core/error/failures.dart';
import 'package:entertainer/features/review/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviews({
    String? offerId,
    String? merchantId,
    int? rating,
    String? status,
    String? sortBy,
    int page,
    int limit,
  });

  Future<Either<Failure, RatingSummaryEntity>> getRatingSummary({
    String? offerId,
    String? merchantId,
  });

  Future<Either<Failure, ReviewEntity>> createReview({
    String? offerId,
    String? merchantId,
    required int rating,
    String? title,
    required String comment,
    List<String>? photos,
  });

  Future<Either<Failure, ReviewEntity>> updateReview(
    String id, {
    int? rating,
    String? title,
    String? comment,
    List<String>? photos,
  });

  Future<Either<Failure, void>> deleteReview(String id);

  Future<Either<Failure, ReviewEntity>> markHelpful(String reviewId);

  Future<Either<Failure, ReviewEntity>> removeHelpful(String reviewId);

  Future<Either<Failure, void>> reportReview(
    String reviewId,
    String reason,
    String? comment,
  );
}
