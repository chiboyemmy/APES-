import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:t_utils/utils/constants/enums.dart';

import '../../../features/shop/models/order_model.dart';
import '../authentication/authentication_repository.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;

  /* ---------------------------- FUNCTIONS ---------------------------------*/

  /// Get all order related to current User
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      if (userId.isEmpty) throw 'Unable to find user information. Try again in few minutes.';

      // Sub Collection Order -> Replaced with main Collection
      // final result = await _db.collection('Users').doc(userId).collection('Orders').get();
      final result = await _db.collection('Orders').where('userId', isEqualTo: userId).orderBy('updatedAt', descending: true).get();
      return result.docs.map((documentSnapshot) => OrderModel.fromDocSnapshot(documentSnapshot)).toList();
    } catch (e) {
      debugPrint(e.toString());
      throw 'Something went wrong while fetching Order Information. Try again later';
    }
  }

  /// Get Single order of current User
  Future<OrderModel> fetchSingleOrder(String id) async {
    try {
      if (kDebugMode) {
        debugPrint("Order id is $id");
      }
      final result = await _db.collection('Orders').doc(id).get();
      return OrderModel.fromJson(result.id, result.data()!);
    } catch (e) {
      throw 'Something went wrong while fetching Order Information. Try again later';
    }
  }

  /// Store new user order
  Future<void> saveOrder(OrderModel order, String userId) async {
    try {
      await _db.collection('Orders').add(order.toJson()).then((value) {
        _db.collection("Orders").doc(value.id).update({'docId': value.id});
      });
    } catch (e) {
      throw 'Something went wrong while saving Order Information. Try again later';
    }
  }


  /// Cancel Order
  Future<void> cancelOrder(OrderModel order)
  async {
    try {
      await _db.collection('Orders').doc(order.docId).update({
        'orderStatus' : OrderStatus.canceled.name,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Something went wrong while saving Order Information. Try again later';
    }
  }
}
