import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

import '../../../features/shop/models/brand_model.dart';
import '../../../utils/constants/enums.dart';
import '../../abstract/base_repository.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';
import '../../../features/shop/models/old_dummy_brand_category_model.dart';

class BrandRepository extends TBaseRepositoryController<BrandModel> {
  // Singleton instance of the BrandRepository
  static BrandRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  @override
  Future<String> addItem(BrandModel item) async {
    final result = await _db.collection("Brands").add(item.toJson());
    return result.id;
  }

  @override
  Future<List<BrandModel>> fetchAllItems() async {
    final snapshot = await _db.collection("Brands").orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((e) => BrandModel.fromDocSnapshot(e)).toList();
  }

  @override
  Future<BrandModel> fetchSingleItem(String id) async {
    final snapshot = await _db.collection("Brands").doc(id).get();
    return BrandModel.fromDocSnapshot(snapshot);
  }

  @override
  BrandModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return BrandModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(int limit) =>
      _db.collection('Brands').orderBy('createdAt', descending: true).limit(limit);

  @override
  Future<void> updateItem(BrandModel item) async {
    await _db.collection("Brands").doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await _db.collection("Brands").doc(id).update(json);
  }

  @override
  Future<void> deleteItem(BrandModel item) async {
    await _db.collection("Brands").doc(item.id).delete();
  }


  /// Get Featured categories
  Future<List<BrandModel>> getFeaturedBrands() async {
    try {
      final snapshot = await _db.collection("Brands").where('IsFeatured', isEqualTo: true).limit(4).get();
      final result = snapshot.docs.map((e) => BrandModel.fromDocSnapshot(e)).toList();
      return result;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on SocketException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw 'Something Went Wrong! Please try again.';
    }
  }


  /// Get Featured categories
  // Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
  //   try {
  //     // Query to get all documents where categoryId matches the provided categoryId
  //     QuerySnapshot brandCategoryQuery = await _db.collection('Brands').where('categoryId', isEqualTo: categoryId).get();
  //
  //     // Extract brandIds from the documents
  //     List<String> brandIds = brandCategoryQuery.docs.map((doc) => doc['brandId'] as String).toList();
  //
  //     // Query to get all documents where the brandId is in the list of brandIds, FieldPath.documentId to query documents in Collection
  //     final brandsQuery = await _db.collection('Brands').where(FieldPath.documentId, whereIn: brandIds).limit(2).get();
  //
  //     // Extract brand names or other relevant data from the documents
  //     List<BrandModel> brands = brandsQuery.docs.map((doc) => BrandModel.fromDocSnapshot(doc)).toList();
  //
  //     return brands;
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } on SocketException catch (e) {
  //     throw e.message;
  //   } on PlatformException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     throw 'Something Went Wrong! Please try again.';
  //   }
  // }
  Future<List<BrandModel>> getBrandsForCategory(String categoryId, int limit) async {
    try {
      // Query to get all documents where productId matches the provided categoryId & Fetch limited or unlimited based on limit
      QuerySnapshot<Map<String, dynamic>> querySnapshot = limit == -1
          ? await _db.collection('Brands').where('categories.id', isEqualTo: categoryId).get()
          : await _db.collection('Brands').where('categories.id', isEqualTo: categoryId).limit(limit).get();

      // Map Products
      final brands = querySnapshot.docs.map((doc) => BrandModel.fromDocSnapshot(doc)).toList();

      return brands;
    } on FirebaseException catch (e) {
          throw e.message!;
        } on SocketException catch (e) {
          throw e.message;
        } on PlatformException catch (e) {
          throw e.message!;
        } catch (e) {
          throw 'Something Went Wrong! Please try again.';
        }
  }



  /// Upload Brands to Firebase along with images
  Future<void> uploadDummyData(List<BrandModel> brands) async {
    try {
      final storage = Get.put(TFirebaseStorageService());

      for (var brand in brands) {
        // Get image file from assets
        final file = await storage.getImageDataFromAssets(brand.imageURL);

        // Upload image and get its URL
        final url = await storage.uploadImageData(
          'Brands',
          file,
          path.basename(brand.name),
          MediaCategory.brands.name,
        );

        // Assign uploaded URL to brand model
        brand.imageURL = url;

        // Store brand in Firestore
        await _db.collection("Brands").doc(brand.id).set(brand.toJson());
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } on SocketException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Upload Brand Categories to Firebase
  Future<void> uploadBrandCategoryDummyData(List<BrandCategoryModel> brandCategory) async {
    try {
      for (var entry in brandCategory) {
        await _db.collection("BrandCategory").doc().set(entry.toJson());
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } on SocketException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }
}
