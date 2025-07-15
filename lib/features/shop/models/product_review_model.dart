import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';

class ReviewModel {
  String id;
  String productId;
  String productName;
  String productImage;
  String userId;
  String userName;
  String? userProfileImage;
  double rating;
  String reviewText;
  List<String>? mediaUrls;
  DateTime createdAt;
  DateTime updatedAt;
  bool isApproved;

  ReviewModel({
    required this.id,
    required this.productId,
    this.productName = '',
    this.productImage = '',
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.rating,
    this.reviewText = '',
    this.mediaUrls,
    this.isApproved = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  // toJson method for Firestore
  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'rating': rating,
        'reviewText': reviewText,
        'mediaUrls': mediaUrls,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isApproved': isApproved,
      };

  // fromJson method for Firestore
  factory ReviewModel.fromJson(String id, Map<String, dynamic> json) => ReviewModel(
        id: id,
        productId: json['productId'],
        productName: json['productName'],
        productImage: json['productImage'],
        userId: json['userId'],
        userName: json['userName'],
        userProfileImage: json.containsKey('userProfileImage') ? json['userProfileImage'] : null,
        rating: json['rating'].toDouble(),
        reviewText: json['reviewText'],
        mediaUrls: json.containsKey('mediaUrls') ? List<String>.from(json['mediaUrls']) : [],
        createdAt: json['createdAt'].toDate(),
        updatedAt: json['updatedAt'].toDate(),
        isApproved: json['isApproved'],
      );

  /// Factory method to create AttributeModel from Firestore document snapshot
  factory ReviewModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReviewModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of AttributeModel from QuerySnapshot (for retrieving multiple attributes)
  static ReviewModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromJson(doc.id, data);
  }

  static ReviewModel empty() => ReviewModel(
      id: '', rating: 0, createdAt: DateTime.now(), productId: '', userId: '', userName: '', updatedAt: DateTime.now());
}
