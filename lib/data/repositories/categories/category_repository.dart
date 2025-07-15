import 'package:cwt_ecommerce_app/utils/exceptions/firebase_exceptions.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/shop/models/category_model.dart';
import '../../../features/shop/models/product_category_model.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../abstract/base_repository.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';
import 'package:path/path.dart' as path;

class CategoryRepository extends TBaseRepositoryController<CategoryModel> {
  static CategoryRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;

  /* ---------------------------- FUNCTIONS ---------------------------------*/
  @override
  Future<String> addItem(CategoryModel item) async {
    final result = await db.collection('Categories').add(item.toJson());
    return result.id;
  }

  @override
  Future<void> deleteItem(CategoryModel item) async {
    await db.collection("Categories").doc(item.id).delete();
  }

  @override
  Future<List<CategoryModel>> fetchAllItems() async {
    final documentSnapshot = await db.collection("Categories").orderBy('createdAt', descending: true).get();
    final category = documentSnapshot.docs.map((vt) => CategoryModel.fromDocSnapshot(vt)).toList();
    return category;
  }

  @override
  Future<CategoryModel> fetchSingleItem(String id) async {
    final documentSnapshot = await db.collection("Categories").doc(id).get();
    if (documentSnapshot.exists) {
      return CategoryModel.fromDocSnapshot(documentSnapshot);
    } else {
      return CategoryModel.empty();
    }
  }



  @override
  CategoryModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return CategoryModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(limit) => db.collection('Categories').orderBy('createdAt', descending: true).limit(limit);

  @override
  Future<void> updateItem(CategoryModel item) async {
    await db.collection("Categories").doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection("Categories").doc(id).update(json);
  }
  // /// Get all categories
  // Future<List<CategoryModel>> getAllCategories() async {
  //   try {
  //     final snapshot = await _db.collection("Categories").get();
  //     final result = snapshot.docs.map((e) => CategoryModel.fromDocSnapshot(e)).toList();
  //     return result;
  //   } on FirebaseException catch (e) {
  //     throw TFirebaseException(e.code).message;
  //   } on PlatformException catch (e) {
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again';
  //   }
  // }

  /// Get Featured categories
  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      final snapshot = await _db.collection("Categories").where('parentId', isEqualTo: categoryId).get();
      final result = snapshot.docs.map((e) => CategoryModel.fromDocSnapshot(e)).toList();
      return result;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload Categories to the Cloud Firebase
  Future<void> uploadDummyData(List<CategoryModel> categories) async {
    try {
      // Upload all the Categories along with their Images
      final storage = Get.put(TFirebaseStorageService());

      // Loop through each category
      for (var category in categories) {
        // Get ImageData link from the local assets
        final file = await storage.getImageDataFromAssets(category.imageURL);

        // Upload Image and Get its URL
        final url = await storage.uploadImageData('Categories', file, path.basename(category.name), MediaCategory.categories.name);

        // Assign URL to Category.image attribute
        category.imageURL = url;

        // Store Category in Firestore
        await _db.collection("Categories").doc(category.id).set(category.toJson());
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload Categories to the Cloud Firebase
  Future<void> uploadProductCategoryDummyData(List<ProductCategoryModel> productCategory) async {
    try {
      // Loop through each category
      for (var entry in productCategory) {
        // Store Category in Firestore
        await _db.collection("ProductCategory").doc().set(entry.toJson());
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
