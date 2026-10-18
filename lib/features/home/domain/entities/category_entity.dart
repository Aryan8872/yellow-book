class CategoryEntity {
  final String id;
  final String name;
  final String iconPath;
  final int offerCount;
  final String? color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconPath,
    this.offerCount = 0,
    this.color,
  });
}
