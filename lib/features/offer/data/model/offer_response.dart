import 'package:entertainer/core/network/common_response.dart';
import 'package:entertainer/features/offer/data/model/offer_model.dart';
import 'package:entertainer/features/offer/domain/entity/offer_entity.dart';

class OfferResponse extends CommonResponse {
  final OfferModel data;

  OfferResponse({
    required this.data,
    required super.success,
    required super.statusCode,
    required super.message,
    super.errorCode,
    required super.timestamp,
    required super.correlationId,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    final offerData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return OfferResponse(
      data: OfferModel.fromJson(offerData),
      success: json['success'] as bool? ?? true,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      errorCode: json['errorCode']?.toString(),
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      correlationId: json['correlationId']?.toString() ?? '',
    );
  }

  OfferEntity toEntity() => data.toEntity();
}

class PaginatedOfferResponse extends CommonResponse {
  final List<OfferModel> offers;
  final int count;
  final int total;
  final int page;
  final int limit;

  PaginatedOfferResponse({
    required this.offers,
    required this.count,
    required this.total,
    required this.page,
    required this.limit,
    required super.success,
    required super.statusCode,
    required super.message,
    super.errorCode,
    required super.timestamp,
    required super.correlationId,
  });

  factory PaginatedOfferResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawList = dataMap['offers'] ?? json['offers'] ?? json['data'] ?? [];
    final list = (rawList is List) ? rawList : [];

    final offerModels = list
        .whereType<Map<String, dynamic>>()
        .map((item) => OfferModel.fromJson(item))
        .toList();   //converting each object inside the array or list to model instance and converting to a list

    final metaMap = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : dataMap;

    final total = (metaMap['total'] as num?)?.toInt() ?? offerModels.length;
    final count = (metaMap['count'] as num?)?.toInt() ?? offerModels.length;
    final page = (metaMap['page'] as num?)?.toInt() ?? (metaMap['pageNumber'] as num?)?.toInt() ?? 1;
    final limit = (metaMap['limit'] as num?)?.toInt() ?? 10;

    return PaginatedOfferResponse(
      offers: offerModels,
      count: count,
      total: total,
      page: page,
      limit: limit,
      success: json['success'] as bool? ?? true,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      errorCode: json['errorCode']?.toString(),
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      correlationId: json['correlationId']?.toString() ?? '',
    );
  }

  PaginatedOfferEntity toEntity() {
    return PaginatedOfferEntity(
      offers: offers.map((model) => model.toEntity()).toList(),
      count: count,
      total: total,
      page: page,
      limit: limit,
    );
  }
}
