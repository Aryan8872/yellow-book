sealed class ReviewState {
  const ReviewState();
}

final class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

final class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

final class ReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final int page;
  final bool hasMore;

  const ReviewsLoaded({
    required this.reviews,
    required this.page,
    required this.hasMore,
  });
}

final class RatingSummaryLoaded extends ReviewState {
  final RatingSummaryEntity summary;

  const RatingSummaryLoaded(this.summary);
}

final class ReviewCreated extends ReviewState {
  final ReviewEntity review;

  const ReviewCreated(this.review);
}

final class ReviewUpdated extends ReviewState {
  final ReviewEntity review;

  const ReviewUpdated(this.review);
}

final class ReviewDeleted extends ReviewState {
  const ReviewDeleted();
}

final class ReviewHelpfulMarked extends ReviewState {
  final ReviewEntity review;

  const ReviewHelpfulMarked(this.review);
}

final class ReviewHelpfulRemoved extends ReviewState {
  final ReviewEntity review;

  const ReviewHelpfulRemoved(this.review);
}

final class ReviewReported extends ReviewState {
  const ReviewReported();
}

final class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);
}
