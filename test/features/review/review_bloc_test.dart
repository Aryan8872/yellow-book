import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/features/review/domain/entities/review_entity.dart';
import 'package:entertainer/features/review/domain/repositories/review_repository.dart';
import 'package:entertainer/features/review/presentation/bloc/review_bloc.dart';
import 'package:entertainer/features/review/presentation/bloc/review_event.dart';
import 'package:entertainer/features/review/presentation/bloc/review_state.dart';

class _MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late _MockReviewRepository repository;

  setUp(() {
    repository = _MockReviewRepository();
  });

  test('appends subsequent review pages', () async {
    final firstReview = _review('review-1');
    final secondReview = _review('review-2');
    when(
      () => repository.getReviews(
        offerId: 'offer-1',
        merchantId: null,
        rating: null,
        status: null,
        sortBy: null,
        page: 1,
        limit: 10,
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<ReviewEntity>>([firstReview]),
    );
    when(
      () => repository.getReviews(
        offerId: 'offer-1',
        merchantId: null,
        rating: null,
        status: null,
        sortBy: null,
        page: 2,
        limit: 10,
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<ReviewEntity>>([secondReview]),
    );

    final bloc = ReviewBloc(repository);
    bloc.add(
      const FetchReviewsRequested(offerId: 'offer-1', page: 1, limit: 10),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.add(
      const FetchReviewsRequested(offerId: 'offer-1', page: 2, limit: 10),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = bloc.state as ReviewsLoaded;
    expect(state.page, 2);
    expect(state.reviews.map((review) => review.id), ['review-1', 'review-2']);
    await bloc.close();
  });
}

ReviewEntity _review(String id) {
  final now = DateTime.utc(2026);
  return ReviewEntity(
    id: id,
    userId: 'user-1',
    rating: 5,
    comment: 'Great offer',
    photos: const [],
    isVerified: true,
    isFeatured: false,
    helpfulCount: 0,
    reportCount: 0,
    status: 'PUBLISHED',
    createdAt: now,
    updatedAt: now,
  );
}
