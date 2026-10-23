class ReviewEntity {
  final String id;
  final String userId;
  final String? offerId;
  final String? merchantId;
  final int rating;
  final String? title;
  final String comment;
  final List<String> photos;
  final bool isVerified;
  final bool isFeatured;
  final int helpfulCount;
  final int reportCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserEntity? user;
  final OfferSummaryEntity? offer;
  final MerchantSummaryEntity? merchant;

  ReviewEntity({
    required this.id,
    required this.userId,
    this.offerId,
    this.merchantId,
    required this.rating,
    this.title,
    required this.comment,
    required this.photos,
    required this.isVerified,
    required this.isFeatured,
    required this.helpfulCount,
    required this.reportCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.offer,
    this.merchant,
  });

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      offerId: json['offerId'] as String?,
      merchantId: json['merchantId'] as String?,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      isVerified: json['isVerified'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'PUBLISHED',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: json['user'] != null ? UserEntity.fromJson(json['user'] as Map<String, dynamic>) : null,
      offer: json['offer'] != null ? OfferSummaryEntity.fromJson(json['offer'] as Map<String, dynamic>) : null,
      merchant: json['merchant'] != null ? MerchantSummaryEntity.fromJson(json['merchant'] as Map<String, dynamic>) : null,
    );
  }
}

class UserEntity {
  final String id;
  final String? name;
  final String? avatarUrl;

  UserEntity({
    required this.id,
    this.name,
    this.avatarUrl,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class OfferSummaryEntity {
  final String id;
  final String title;

  OfferSummaryEntity({
    required this.id,
    required this.title,
  });

  factory OfferSummaryEntity.fromJson(Map<String, dynamic> json) {
    return OfferSummaryEntity(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}

class MerchantSummaryEntity {
  final String id;
  final String name;

  MerchantSummaryEntity({
    required this.id,
    required this.name,
  });

  factory MerchantSummaryEntity.fromJson(Map<String, dynamic> json) {
    return MerchantSummaryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class RatingSummaryEntity {
  final double average;
  final int total;
  final Map<int, int> distribution;

  RatingSummaryEntity({
    required this.average,
    required this.total,
    required this.distribution,
  });

  factory RatingSummaryEntity.fromJson(Map<String, dynamic> json) {
    final distJson = json['distribution'] as Map<String, dynamic>? ?? {};
    final distribution = <int, int>{};
    distJson.forEach((key, value) {
      distribution[int.parse(key)] = value as int;
    });

    return RatingSummaryEntity(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      total: json['total'] as int? ?? 0,
      distribution: distribution,
    );
  }
}
