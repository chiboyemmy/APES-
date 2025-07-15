import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:t_utils/t_utils.dart';
import 'category_model.dart';

class BrandModel {
  String id;
  String name;
  String imageURL;
  bool isFeatured;
  bool isActive;
  int? productsCount;
  int? viewCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  List<CategoryModel>? categories;

  BrandModel({
    required this.id,
    required this.imageURL,
    required this.name,
    this.isFeatured = false,
    this.isActive = true,
    this.productsCount,
    this.viewCount = 0,
    this.categories,
    this.createdAt,
    this.updatedAt,
  });

  /// Empty Helper Function
  static BrandModel empty() => BrandModel(id: '', imageURL: '', name: '');

  String get formattedDate => TFormatter.formatDateAndTime(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDateAndTime(updatedAt);

  /// Convert model to Json structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageURL': imageURL,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'productsCount': productsCount ?? 0,
      'viewCount': viewCount ?? 0,
      'categories': categories?.map((category) => category.toJson()).toList() ?? [], // Ensure it's an empty list if null
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Factory method to create CategoryModel from Firestore document snapshot
  factory BrandModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BrandModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of UserModel from QuerySnapshot (for retrieving multiple users)
  static BrandModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrandModel.fromJson(doc.id, data);
  }

  /// Map Json document snapshot from Firebase to BrandModel
  factory BrandModel.fromJson(String id, Map<String, dynamic> data) {
    if (data.isEmpty) return BrandModel.empty();
    return BrandModel(
      id: id,
      name: data['name'] ?? '',
      imageURL: data['imageURL'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isActive: data.containsKey('isActive') ? data['isActive'] ?? true : true,
      productsCount: int.parse((data['productsCount'] ?? 0).toString()),
      viewCount: int.parse((data['viewCount'] ?? 0).toString()),
      categories: data.containsKey('categories') ? (data['categories'] as List).map((item) => CategoryModel.fromJson(item['id'], item)).toList() : [],
      createdAt: data.containsKey('createdAt') ? data['createdAt']?.toDate() : null,
      updatedAt: data.containsKey('updatedAt') ? data['updatedAt']?.toDate() : null,
    );
  }
}
