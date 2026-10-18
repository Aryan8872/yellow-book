import 'package:dio/dio.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? imageUrl;
  final String? color;
  final int offerCount;
  final bool isActive;
  final int displayOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.imageUrl,
    this.color,
    required this.offerCount,
    required this.isActive,
    required this.displayOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,

      name: json['name'] as String,
      slug: json['slug'] as String,
      iconUrl: json['iconUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      color: json['color'] as String?,
      offerCount: json['offerCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }
}

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get('/categories', queryParameters: {'isActive': true});
    return (response.data as List)
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
