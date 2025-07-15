import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/formatters/formatter.dart';

class CouponModel {
  String id;
  String code;
  String description;
  DiscountType discountType; // 'percentage' or 'flat'
  double discountValue;
  DateTime? startDate;
  DateTime? endDate;
  int usageLimit;
  int usageCount;
  bool isActive;
  DateTime? createdAt;
  DateTime? updateAt;

  CouponModel({
    required this.id,
    required this.code,
    this.description = '',
    this.discountType = DiscountType.percentage,
    required this.discountValue,
    this.startDate,
    this.endDate,
    this.usageLimit = -1,
    this.usageCount = 0,
    this.isActive = true,
    this.createdAt,
    this.updateAt
  });
  String get formattedDate => TFormatter.formatDate(createdAt);
  String get formattedUpdateDate => TFormatter.formatDate(updateAt);
  String get formattedStartDate => TFormatter.formatDate(startDate);
  String get formattedEndDate => TFormatter.formatDate(endDate);

  // Convert Coupon to Firestore format
  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'code': code,
      'description': description,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'startDate': startDate,
      'endDate': endDate,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updateAt': updateAt,
    };
  }

  // Retrieve Coupon from Firestore data
  static CouponModel fromJson(String id, Map<String, dynamic> data) {
    try{
      return CouponModel(
        id: id,
        code: data['code'],
        description: data['description'],
        discountType: data.containsKey('discountType')
            ? DiscountType.values.firstWhere((e) => e.name == data['discountType'], orElse: () => DiscountType.percentage)
            : DiscountType.percentage,
        discountValue: data['discountValue'].toDouble(),
        startDate: data['startDate'].toDate(),
        endDate: data['endDate'].toDate(),
        usageLimit: data['usageLimit'],
        usageCount: data['usageCount'],
        isActive: data.containsKey('isActive') ? data['isActive'] : true,
        createdAt: data.containsKey('createdAt') ? data['createdAt']?.toDate() : null,
        updateAt: data.containsKey('updateAt') ? data['updateAt']?.toDate() : null,
      );
    }catch(e,stacktrace){
      if (kDebugMode) {
        print("Error: $e");
      }
      throw Exception("Error is $e and stacktrace is $stacktrace");
    }

  }

  /// Factory method to create AttributeModel from Firestore document snapshot
  factory CouponModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CouponModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of AttributeModel from QuerySnapshot (for retrieving multiple attributes)
  static CouponModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel.fromJson(doc.id, data);
  }

  static CouponModel empty() => CouponModel(
      id: '', code: '', discountType: DiscountType.percentage, discountValue: 0, endDate: DateTime.now(), startDate: DateTime.now());
}
