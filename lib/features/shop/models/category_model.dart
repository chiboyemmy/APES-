import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/formatters/formatter.dart';
import 'brand_model.dart';

class CategoryModel {
  String id;
  String name;
  String imageURL;
  String parentId;
  bool isActive;
  bool isFeatured;
  int priority;
  DateTime? createdAt;
  DateTime? updatedAt;
  int numberOfProducts;
  int viewCount;
  String createdBy;
  String updatedBy;
  List<BrandModel>? brands;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.isActive,
    this.isFeatured = false,
    this.parentId = '',
    this.priority = 1,
    this.createdAt,
    this.updatedAt,
    this.numberOfProducts = 0,
    this.viewCount = 0,
    this.brands,
    this.createdBy = '',
    this.updatedBy = '',
  });

  /// Convert model to JSON structure to store in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageURL': imageURL,
      'parentId': parentId,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
      'numberOfProducts': numberOfProducts,
      'viewCount': viewCount,
      'brands': brands?.map((brand) => brand.toJson()).toList() ?? [],
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  String get formattedDate => TFormatter.formatDateAndTime(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDateAndTime(updatedAt);

  /// Factory method to create CategoryModel from Firestore document snapshot
  factory CategoryModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CategoryModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of UserModel from QuerySnapshot (for retrieving multiple users)
  static CategoryModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.fromJson(doc.id, data);
  }

  /// Map JSON data to the CategoryModel with data.containsKey check
  factory CategoryModel.fromJson(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data.containsKey('name') ? data['name'] ?? '' : '',
      imageURL: data.containsKey('imageURL') ? data['imageURL'] ?? '' : '',
      parentId: data.containsKey('parentId') ? data['parentId'] ?? '' : '',
      isFeatured: data.containsKey('isFeatured') ? data['isFeatured'] ?? false : false,
      isActive: data.containsKey('isActive') ? data['isActive'] ?? true : true,
      priority: data.containsKey('priority') ? data['priority'] ?? 2 : 2,
      // Default to medium priority
      createdAt: data.containsKey('createdAt') && data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data.containsKey('updatedAt') && data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      numberOfProducts: data.containsKey('numberOfProducts') ? data['numberOfProducts'] ?? 0 : 0,
      viewCount: data.containsKey('viewCount') ? data['viewCount'] ?? 0 : 0,
      brands: data.containsKey('brands') ? (data['brands'] as List).map((item) => BrandModel.fromJson(item['id'],item)).toList() : [],
      createdBy: data.containsKey('createdBy') ? data['createdBy'] ?? '' : '',
      updatedBy: data.containsKey('updatedBy') ? data['updatedBy'] ?? '' : '',
    );
  }

  /// Helper function to return an empty CategoryModel
  static CategoryModel empty() =>
      CategoryModel(id: '', imageURL: '', name: '', isFeatured: false, isActive: false, createdBy: '', updatedBy: '');
}
