import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../../../features/shop/models/banner_model.dart';
import '../../../utils/constants/enums.dart';
import '../../abstract/base_repository.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class BannerRepository extends TBaseRepositoryController<BannerModel> {
  // Singleton instance of the BannerRepository
  static BannerRepository get instance => Get.find();

  @override
  Future<String> addItem(BannerModel item) async {
    final result = await db.collection("Banners").add(item.toJson());
    return result.id;
  }

  @override
  Future<List<BannerModel>> fetchAllItems() async {
    final now = Timestamp.fromDate(DateTime.now());
    final snapshot = await db
        .collection("Banners")
        .where("isActive", isEqualTo: true)
        .where("isFeatured", isEqualTo: true)
        .where("startDate", isLessThanOrEqualTo: now)
        .where("endDate", isGreaterThanOrEqualTo: now)
        .orderBy('createdAt', descending: true)
        .get();
    final result = snapshot.docs.map((e) => BannerModel.fromDocSnapshot(e)).toList();
    return result;
  }

  @override
  Future<BannerModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection("Banners").doc(id).get();
    final result = BannerModel.fromDocSnapshot(snapshot);
    return result;
  }

  @override
  BannerModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return BannerModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(limit) => db.collection('Banners').orderBy('createdAt', descending: true).limit(limit);

  @override
  Future<void> updateItem(BannerModel item) async {
    await db.collection("Banners").doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection("Banners").doc(id).update(json);
  }

  @override
  Future<void> deleteItem(BannerModel item) async {
    await db.collection("Banners").doc(item.id).delete();
  }

  /// Upload Banners to the Cloud Firebase
  Future<void> uploadBannersDummyData(List<BannerModel> banners) async {
    try {
      // Upload all the Categories along with their Images
      final storage = Get.put(TFirebaseStorageService());
      // Loop through each category
      for (var entry in banners) {
        // Get ImageData link from the local assets
        final thumbnail = await storage.getImageDataFromAssets(entry.imageUrl);

        // Upload Image and Get its URL
        final url = await storage.uploadImageData('Banners', thumbnail, path.basename(entry.imageUrl), MediaCategory.banners.name);

        // Assign URL to Brand.image attribute
        entry.imageUrl = url;

        // Store Category in Firestore
        await db.collection("Banners").doc().set(entry.toJson());
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }
}
