class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? handle;
  final int? rank;
  final String? parentCategoryId;
  final CategoryModel? parentCategory;
  final List<CategoryModel>? categoryChildren;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.handle,
    this.rank,
    this.parentCategoryId,
    this.parentCategory,
    this.categoryChildren,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      handle: json['handle'],
      rank: json['rank'],
      parentCategoryId: json['parent_category_id'],
      parentCategory: json['parent_category'] != null
          ? CategoryModel.fromJson(json['parent_category'])
          : null,
      categoryChildren: json['category_children'] != null
          ? (json['category_children'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : [],
    );
  }
}
