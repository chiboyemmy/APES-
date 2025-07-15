import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_app/features/shop/models/shipping_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:t_utils/utils/constants/enums.dart';
import '../../../utils/formatters/formatter.dart';
import '../../personalization/models/address_model.dart';
import 'cart_item_model.dart';
import 'coupon_model.dart';
import 'order_activity.dart';

class OrderModel {
  final String docId;
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userDeviceToken;
  final List<CartItemModel> products;

  // Pricing fields
  final double subTotal; // Sum of product prices without tax, shipping, or discount
  final double shippingAmount; // Shipping cost
  final double taxRate; // Tax rate (e.g., 5% = 0.05)
  final double taxAmount; // Tax calculated after discount is applied
  final CouponModel? coupon; // Coupon used for the order
  final double couponDiscountAmount; // Discount from coupon
  final int pointsUsed; // Number of points used by the customer
  final double pointsDiscountAmount; // Discount value from points used
  final double totalDiscountAmount; // Sum of all discounts (coupon + points)
  final double totalAmount; // Final total after applying all discounts, tax, and shipping

  // Other Variables
  final PaymentStatus paymentStatus;
  OrderStatus orderStatus;
  final DateTime orderDate;
  final DateTime? shippingDate;
  final AddressModel shippingAddress;
  final AddressModel? billingAddress;
  final bool billingAddressSameAsShipping;
  final ShippingInfo shippingInfo;
  final List<OrderActivity> activities;
  final int itemCount;
  final DateTime createdAt;
  DateTime updatedAt;
  final String adminNote;

  OrderModel({
    required this.docId,
    required this.id,
    required this.userId,
    this.userName = '',
    this.userEmail = '',
    required this.userDeviceToken,
    required this.products,
    required this.subTotal,
    required this.shippingAmount,
    required this.taxRate,
    required this.taxAmount,
    this.coupon,
    required this.couponDiscountAmount,
    required this.pointsUsed,
    required this.pointsDiscountAmount,
    required this.totalDiscountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.orderDate,
    this.shippingDate,
    required this.shippingAddress,
    this.billingAddress,
    required this.shippingInfo,
    required this.activities,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
    this.adminNote = '',
    this.billingAddressSameAsShipping = true,
  });

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedOrderDate => TFormatter.formatDate(orderDate);

  String get formattedOrderDateTime => TFormatter.formatDateAndTime(orderDate);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Helper method to calculate subtotal (before tax and shipping)
  double calculateSubTotal() {
    return products.fold(0.0, (previous, product) => previous + (product.salePrice * product.quantity));
  }

  /// Helper method to calculate total discount amount (coupon + points)
  double calculateTotalDiscount() {
    return couponDiscountAmount + pointsDiscountAmount;
  }

  /// Helper method to calculate tax after discounts
  double calculateTaxAfterDiscount() {
    final discountAdjustedSubTotal = calculateSubTotal() - calculateTotalDiscount();
    final tax = (discountAdjustedSubTotal > 0 ? discountAdjustedSubTotal : 0.0) * taxRate;
    return tax;
  }

  /// Helper method to calculate grand total
  double calculateGrandTotal() {
    final discountAdjustedSubTotal = calculateSubTotal() - calculateTotalDiscount();
    final taxAmount = calculateTaxAfterDiscount(); // Use this when taxRate Applied
    final grandTotal = (discountAdjustedSubTotal > 0 ? discountAdjustedSubTotal : 0.0) + taxAmount + shippingAmount;
    return grandTotal;
  }

  /// JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userDeviceToken': userDeviceToken,
      'products': products.map((product) => product.toJson()).toList(),
      'subTotal': subTotal,
      'shippingAmount': shippingAmount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'coupon': coupon?.toJson(),
      'couponDiscountAmount': couponDiscountAmount,
      'pointsUsed': pointsUsed,
      'pointsDiscountAmount': pointsDiscountAmount,
      'totalDiscountAmount': calculateTotalDiscount(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus.name,
      'orderStatus': orderStatus.name,
      'orderDate': orderDate,
      'shippingDate': shippingDate,
      'billingAddressSameAsShipping': billingAddressSameAsShipping,
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress?.toJson(),
      'shippingInfo': shippingInfo.toJson(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'itemCount': itemCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'adminNote': adminNote,
    };
  }

  static OrderModel fromJson(String id, Map<String, dynamic> data) {
    try {
      return OrderModel(
        docId: id,
        id: data.containsKey('id') && data['id'] != null ? data['id'] as String : '',
        userId: data.containsKey('userId') && data['userId'] != null ? data['userId'] as String : '',
        userName: data.containsKey('userName') && data['userName'] != null ? data['userName'] as String : '',
        userEmail: data.containsKey('userEmail') && data['userEmail'] != null ? data['userEmail'] as String : '',
        userDeviceToken:
            data.containsKey('userDeviceToken') && data['userDeviceToken'] != null ? data['userDeviceToken'] as String : '',
        products: data.containsKey('products') && data['products'] != null
            ? (data['products'] as List).map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)).toList()
            : [],
        subTotal: data.containsKey('subTotal') ? (data['subTotal'] as num?)?.toDouble() ?? 0.0 : 0.0,
        shippingAmount: data.containsKey('shippingAmount') ? (data['shippingAmount'] as num?)?.toDouble() ?? 0.0 : 0.0,
        taxRate: data.containsKey('taxRate') ? (data['taxRate'] as num?)?.toDouble() ?? 0.0 : 0.0,
        taxAmount: data.containsKey('taxAmount') ? (data['taxAmount'] as num?)?.toDouble() ?? 0.0 : 0.0,
        coupon: data.containsKey('coupon') && data['coupon'] != null
            ? CouponModel.fromJson(data['coupon']['id'] ?? '', data['coupon'] as Map<String, dynamic>)
            : null,
        couponDiscountAmount:
            data.containsKey('couponDiscountAmount') ? (data['couponDiscountAmount'] as num?)?.toDouble() ?? 0.0 : 0.0,
        pointsUsed: data.containsKey('pointsUsed') ? data['pointsUsed'] ?? 0 : 0,
        pointsDiscountAmount:
            data.containsKey('pointsDiscountAmount') ? (data['pointsDiscountAmount'] as num?)?.toDouble() ?? 0.0 : 0.0,
        totalDiscountAmount:
            data.containsKey('totalDiscountAmount') ? (data['totalDiscountAmount'] as num?)?.toDouble() ?? 0.0 : 0.0,
        totalAmount: data.containsKey('totalAmount') ? (data['totalAmount'] as num?)?.toDouble() ?? 0.0 : 0.0,
        paymentStatus: data.containsKey('paymentStatus') && data['paymentStatus'] != null
            ? PaymentStatus.values.firstWhere((e) => e.name == data['paymentStatus'], orElse: () => PaymentStatus.unpaid)
            : PaymentStatus.unpaid,
        orderStatus: data.containsKey('orderStatus') && data['orderStatus'] != null
            ? OrderStatus.values.firstWhere((e) => e.name == data['orderStatus'], orElse: () => OrderStatus.pending)
            : OrderStatus.pending,
        orderDate: data.containsKey('orderDate') && data['orderDate'] != null
            ? (data['orderDate'] as Timestamp).toDate()
            : DateTime.now(),
        shippingDate: data.containsKey('shippingDate') && data['shippingDate'] != null
            ? (data['shippingDate'] as Timestamp).toDate()
            : null,
        shippingAddress: data.containsKey('shippingAddress') && data['shippingAddress'] != null
            ? AddressModel.fromJson(data['shippingAddress']['id'], data['shippingAddress'] as Map<String, dynamic>)
            : AddressModel.empty(),
        billingAddress: data.containsKey('billingAddress') && data['billingAddress'] != null
            ? AddressModel.fromJson(data['billingAddress']['id'], data['billingAddress'] as Map<String, dynamic>)
            : AddressModel.empty(),
        billingAddressSameAsShipping:
            data.containsKey('billingAddressSameAsShipping') && data['billingAddressSameAsShipping'] != null
                ? data['billingAddressSameAsShipping'] as bool
                : true,
        shippingInfo: data.containsKey('shippingInfo') && data['shippingInfo'] != null
            ? ShippingInfo.fromJson(data['shippingInfo'] as Map<String, dynamic>)
            : ShippingInfo.empty(),
        activities: data.containsKey('activities') && data['activities'] != null
            ? (data['activities'] as List).map((item) => OrderActivity.fromJson(item as Map<String, dynamic>)).toList()
            : [],
        itemCount: data.containsKey('itemCount') && data['itemCount'] != null ? data['itemCount'] as int : 0,
        createdAt: data.containsKey('createdAt') && data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data.containsKey('updatedAt') && data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
        adminNote: data.containsKey('adminNote') && data['adminNote'] != null ? data['adminNote'] as String : '',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Factory method to create AttributeModel from Firestore document snapshot
  factory OrderModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    debugPrint(data.toString());
    return OrderModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of AttributeModel from QuerySnapshot (for retrieving multiple attributes)
  static OrderModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson(doc.id, data);
  }

  /// Factory method to create an empty order model (for initialization)
  static OrderModel empty() {
    return OrderModel(
      docId: '',
      id: '',
      userId: '',
      userDeviceToken: '',
      subTotal: 0.0,
      shippingAmount: 0.0,
      taxRate: 0.0,
      taxAmount: 0.0,
      couponDiscountAmount: 0.0,
      pointsUsed: 0,
      pointsDiscountAmount: 0.0,
      totalDiscountAmount: 0.0,
      totalAmount: 0.0,
      paymentStatus: PaymentStatus.unpaid,
      orderStatus: OrderStatus.pending,
      orderDate: DateTime.now(),
      shippingAddress: AddressModel.empty(),
      shippingInfo: ShippingInfo.empty(),
      activities: [],
      itemCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      products: [],
    );
  }
}
