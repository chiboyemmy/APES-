import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/product_review_model.dart';
import '../../abstract/base_repository.dart';

class ReviewRepository extends TBaseRepositoryController<ReviewModel> {
  // Singleton instance of the ReviewRepository
  static ReviewRepository get instance => Get.find();

  @override
  Future<String> addItem(ReviewModel item) async {
    final result = await db.collection("Reviews").add(item.toJson());
    return result.id;
  }

  Future<List<ReviewModel>> fetchAllItemByProductId(String id) async {
    final snapshot = await db.collection("Reviews").where('productId', isEqualTo: id).get();
    final result = snapshot.docs.map((e) => ReviewModel.fromDocSnapshot(e)).toList();
    return result;
  }

  @override
  Future<List<ReviewModel>> fetchAllItems() async {
    final snapshot = await db.collection("Reviews").orderBy('createdAt', descending: true).get();
    final result = snapshot.docs.map((e) => ReviewModel.fromDocSnapshot(e)).toList();
    return result;
  }

  @override
  Future<ReviewModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection("Reviews").doc(id).get();
    final result = ReviewModel.fromDocSnapshot(snapshot);
    return result;
  }

  @override
  ReviewModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return ReviewModel.fromQuerySnapshot(doc);
  }

  @override
  Query getPaginatedQuery(limit) => db.collection('Reviews').orderBy('createdAt', descending: true).limit(limit);

  @override
  Future<void> updateItem(ReviewModel item) async {
    await db.collection("Reviews").doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection("Reviews").doc(id).update(json);
  }

  @override
  Future<void> deleteItem(ReviewModel item) async {
    await db.collection("Reviews").doc(item.id).delete();
  }
}
