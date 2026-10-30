class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String iconName;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Category',
      slug: json['slug'] as String? ?? 'category',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'directions_car',
    );
  }
}
