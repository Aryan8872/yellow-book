import 'package:dio/dio.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import '../../../domain/entities/review_entity.dart';

abstract class ReviewRemoteDatasource {
  Future<List<ReviewEntity>> getReviews({
    String? offerId,
    String? merchantId,
    int? rating,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  });

  Future<RatingSummaryEntity> getRatingSummary({
    String? offerId,
    String? merchantId,
  });

  Future<ReviewEntity> createReview({
    String? offerId,
    String? merchantId,
    required int rating,
    String? title,
    required String comment,
    List<String>? photos,
  });

  Future<ReviewEntity> updateReview(String id, {
    int? rating,
    String? title,
    String? comment,
    List<String>? photos,
  });

  Future<void> deleteReview(String id);

  Future<ReviewEntity> markHelpful(String reviewId);

  Future<ReviewEntity> removeHelpful(String reviewId);

  Future<void> reportReview(String reviewId, String reason, String? comment);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDatasource {
  final Dio dio;

  ReviewRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ReviewEntity>> getReviews({
    String? offerId,
    String? merchantId,
    int? rating,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      if (offerId != null) 'offerId': offerId,
      if (merchantId != null) 'merchantId': merchantId,
      if (rating != null) 'rating': rating,
      if (status != null) 'status': status,
      if (sortBy != null) 'sortBy': sortBy,
      'page': page,
      'limit': limit,
    };

    final response = await dio.get(
      '/reviews',
      queryParameters: queryParams,
    );

    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }

    final reviewsData = dataMap['data'] as List<dynamic>? ?? [];
    return reviewsData.map((json) => ReviewEntity.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<RatingSummaryEntity> getRatingSummary({
    String? offerId,
    String? merchantId,
  }) async {
    final queryParams = <String, dynamic>{
      if (offerId != null) 'offerId': offerId,
      if (merchantId != null) 'merchantId': merchantId,
    };

    final response = await dio.get(
      '/reviews/summary',
      queryParameters: queryParams,
    );

    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }

    return RatingSummaryEntity.fromJson(dataMap);
  }

  @override
  Future<ReviewEntity> createReview({
    String? offerId,
    String? merchantId,
    required int rating,
    String? title,
    required String comment,
    List<String>? photos,
  }) async {
    final response = await dio.post(
      '/reviews',
      data: {
        if (offerId != null) 'offerId': offerId,
        if (merchantId != null) 'merchantId': merchantId,
        'rating': rating,
        if (title != null) 'title': title,
        'comment': comment,
        if (photos != null) 'photos': photos,
      },
    );

    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }

    return ReviewEntity.fromJson(dataMap);
  }

  @override
  Future<ReviewEntity> updateReview(String id, {
    int? rating,
    String? title,
    String? comment,
    List<String>? photos,
  }) async {
    final response = await dio.put(
      '/reviews/$id',
      data: {
        if (rating != null) 'rating': rating,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
        if (photos != null) 'photos': photos,
      },
    );

    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }

    return ReviewEntity.fromJson(dataMap);
  }

  @override
  Future<void> deleteReview(String id) async {
    await dio.delete('/reviews/$id');
  }

  @override
  Future<ReviewEntity> markHelpful(String reviewId) async {
    final response = await dio.post('/reviews/$reviewId/helpful');
    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }
    return ReviewEntity.fromJson(dataMap);
  }

  @override
  Future<ReviewEntity> removeHelpful(String reviewId) async {
    final response = await dio.delete('/reviews/$reviewId/helpful');
    final raw = response.data;
    Map<String, dynamic> dataMap = {};
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else {
        dataMap = raw;
      }
    }
    return ReviewEntity.fromJson(dataMap);
  }

  @override
  Future<void> reportReview(String reviewId, String reason, String? comment) async {
    await dio.post(
      '/reviews/$reviewId/report',
      data: {
        'reason': reason,
        if (comment != null) 'comment': comment,
      },
    );
  }
}
