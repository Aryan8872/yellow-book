sealed class ReviewEvent {
  const ReviewEvent();
}

final class FetchReviewsRequested extends ReviewEvent {
  final String? offerId;
  final String? merchantId;
  final int? rating;
  final String? status;
  final String? sortBy;
  final int page;
  final int limit;

  const FetchReviewsRequested({
    this.offerId,
    this.merchantId,
    this.rating,
    this.status,
    this.sortBy,
    this.page = 1,
    this.limit = 20,
  });
}

final class FetchRatingSummaryRequested extends ReviewEvent {
  final String? offerId;
  final String? merchantId;

  const FetchRatingSummaryRequested({
    this.offerId,
    this.merchantId,
  });
}

final class CreateReviewRequested extends ReviewEvent {
  final String? offerId;
  final String? merchantId;
  final int rating;
  final String? title;
  final String comment;
  final List<String>? photos;

  const CreateReviewRequested({
    this.offerId,
    this.merchantId,
    required this.rating,
    this.title,
    required this.comment,
    this.photos,
  });
}

final class UpdateReviewRequested extends ReviewEvent {
  final String id;
  final int? rating;
  final String? title;
  final String? comment;
  final List<String>? photos;

  const UpdateReviewRequested({
    required this.id,
    this.rating,
    this.title,
    this.comment,
    this.photos,
  });
}

final class DeleteReviewRequested extends ReviewEvent {
  final String id;

  const DeleteReviewRequested(this.id);
}

final class MarkHelpfulRequested extends ReviewEvent {
  final String reviewId;

  const MarkHelpfulRequested(this.reviewId);
}

final class RemoveHelpfulRequested extends ReviewEvent {
  final String reviewId;

  const RemoveHelpfulRequested(this.reviewId);
}

final class ReportReviewRequested extends ReviewEvent {
  final String reviewId;
  final String reason;
  final String? comment;

  const ReportReviewRequested({
    required this.reviewId,
    required this.reason,
    this.comment,
  });
}
