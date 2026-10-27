import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/network/interceptors/error_interceptor.dart';
import 'package:entertainer/features/review/data/datasources/remote/review_remote_datasource.dart';
import 'package:entertainer/features/review/domain/entities/review_entity.dart';
import 'package:entertainer/features/review/domain/repositories/review_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDatasource remoteDatasource;

  ReviewRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviews({
    String? offerId,
    String? merchantId,
    int? rating,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final reviews = await remoteDatasource.getReviews(
        offerId: offerId,
        merchantId: merchantId,
        rating: rating,
        status: status,
        sortBy: sortBy,
        page: page,
        limit: limit,
      );
      return Right(reviews);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RatingSummaryEntity>> getRatingSummary({
    String? offerId,
    String? merchantId,
  }) async {
    try {
      final summary = await remoteDatasource.getRatingSummary(
        offerId: offerId,
        merchantId: merchantId,
      );
      return Right(summary);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    String? offerId,
    String? merchantId,
    required int rating,
    String? title,
    required String comment,
    List<String>? photos,
  }) async {
    try {
      final review = await remoteDatasource.createReview(
        offerId: offerId,
        merchantId: merchantId,
        rating: rating,
        title: title,
        comment: comment,
        photos: photos,
      );
      return Right(review);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview(
    String id, {
    int? rating,
    String? title,
    String? comment,
    List<String>? photos,
  }) async {
    try {
      final review = await remoteDatasource.updateReview(
        id,
        rating: rating,
        title: title,
        comment: comment,
        photos: photos,
      );
      return Right(review);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String id) async {
    try {
      await remoteDatasource.deleteReview(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> markHelpful(String reviewId) async {
    try {
      final review = await remoteDatasource.markHelpful(reviewId);
      return Right(review);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> removeHelpful(String reviewId) async {
    try {
      final review = await remoteDatasource.removeHelpful(reviewId);
      return Right(review);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reportReview(
    String reviewId,
    String reason,
    String? comment,
  ) async {
    try {
      await remoteDatasource.reportReview(reviewId, reason, comment);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorInterceptor.mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
