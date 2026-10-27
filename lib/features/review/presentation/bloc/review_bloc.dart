import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:entertainer/features/review/domain/entities/review_entity.dart';
import 'package:entertainer/features/review/domain/repositories/review_repository.dart';

import 'review_event.dart';
import 'review_state.dart';

@injectable
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc(this.repository) : super(const ReviewInitial()) {
    on<FetchReviewsRequested>(_onFetchReviews);
    on<FetchRatingSummaryRequested>(_onFetchRatingSummary);
    on<CreateReviewRequested>(_onCreateReview);
    on<UpdateReviewRequested>(_onUpdateReview);
    on<DeleteReviewRequested>(_onDeleteReview);
    on<MarkHelpfulRequested>(_onMarkHelpful);
    on<RemoveHelpfulRequested>(_onRemoveHelpful);
    on<ReportReviewRequested>(_onReportReview);
  }

  Future<void> _onFetchReviews(
    FetchReviewsRequested event,
    Emitter<ReviewState> emit,
  ) async {
    final previousReviews = state is ReviewsLoaded
        ? (state as ReviewsLoaded).reviews
        : const <ReviewEntity>[];
    if (previousReviews.isEmpty) {
      emit(const ReviewLoading());
    }
    final result = await repository.getReviews(
      offerId: event.offerId,
      merchantId: event.merchantId,
      rating: event.rating,
      status: event.status,
      sortBy: event.sortBy,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (failure) {
        if (previousReviews.isNotEmpty) {
          // Keep showing existing reviews while still notifying via error state
          emit(ReviewError(failure.message));
          emit(
            ReviewsLoaded(
              reviews: previousReviews,
              page: event.page > 1 ? event.page - 1 : 1,
              hasMore: false,
            ),
          );
        } else {
          emit(ReviewError(failure.message));
        }
      },
      (reviews) => emit(
        ReviewsLoaded(
          reviews: event.page > 1 ? [...previousReviews, ...reviews] : reviews,
          page: event.page,
          hasMore: reviews.length >= event.limit,
        ),
      ),
    );
  }

  Future<void> _onFetchRatingSummary(
    FetchRatingSummaryRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await repository.getRatingSummary(
      offerId: event.offerId,
      merchantId: event.merchantId,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (summary) => emit(RatingSummaryLoaded(summary)),
    );
  }

  Future<void> _onCreateReview(
    CreateReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await repository.createReview(
      offerId: event.offerId,
      merchantId: event.merchantId,
      rating: event.rating,
      title: event.title,
      comment: event.comment,
      photos: event.photos,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewCreated(review)),
    );
  }

  Future<void> _onUpdateReview(
    UpdateReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await repository.updateReview(
      event.id,
      rating: event.rating,
      title: event.title,
      comment: event.comment,
      photos: event.photos,
    );
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewUpdated(review)),
    );
  }

  Future<void> _onDeleteReview(
    DeleteReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());
    final result = await repository.deleteReview(event.id);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (_) => emit(const ReviewDeleted()),
    );
  }

  Future<void> _onMarkHelpful(
    MarkHelpfulRequested event,
    Emitter<ReviewState> emit,
  ) async {
    final previousState = state;
    final result = await repository.markHelpful(event.reviewId);
    result.fold(
      (failure) {
        emit(ReviewError(failure.message));
        if (previousState is ReviewsLoaded) {
          emit(previousState);
        }
      },
      (review) => emit(ReviewHelpfulMarked(review)),
    );
  }

  Future<void> _onRemoveHelpful(
    RemoveHelpfulRequested event,
    Emitter<ReviewState> emit,
  ) async {
    final previousState = state;
    final result = await repository.removeHelpful(event.reviewId);
    result.fold(
      (failure) {
        emit(ReviewError(failure.message));
        if (previousState is ReviewsLoaded) {
          emit(previousState);
        }
      },
      (review) => emit(ReviewHelpfulRemoved(review)),
    );
  }

  Future<void> _onReportReview(
    ReportReviewRequested event,
    Emitter<ReviewState> emit,
  ) async {
    final previousState = state;
    final result = await repository.reportReview(
      event.reviewId,
      event.reason,
      event.comment,
    );
    result.fold(
      (failure) {
        emit(ReviewError(failure.message));
        if (previousState is ReviewsLoaded) {
          emit(previousState);
        }
      },
      (_) => emit(const ReviewReported()),
    );
  }
}
