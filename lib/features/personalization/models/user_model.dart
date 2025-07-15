import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_utils/utils/constants/enums.dart';
import 'package:t_utils/utils/formatters/formatter.dart';

import '../../../utils/constants/enums.dart';
import '../../shop/models/order_model.dart';
import 'address_model.dart';

/// Model class representing user data.
class UserModel {
  final String id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String phoneNumber;
  String pin;
  String profilePicture;
  AppRole role;

  DateTime? createdAt;
  DateTime? updatedAt;

  bool isProfileActive;
  bool isEmailVerified;
  VerificationStatus verificationStatus;

  int points;
  int orderCount;
  String deviceToken;

  List<OrderModel>? orders;
  List<AddressModel>? addresses;
  List<String>? reviewedProducts;

  /// Constructor for UserModel.
  UserModel({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.userName = '',
    this.phoneNumber = '',
    this.pin = '',
    this.profilePicture = '',
    this.role = AppRole.user,
    this.createdAt,
    this.updatedAt,
    this.deviceToken = '',
    required this.isEmailVerified,
    required this.isProfileActive,
    this.points = 0,
    this.orderCount = 0,
    this.verificationStatus = VerificationStatus.unknown,
    this.orders,
    this.addresses,
    this.reviewedProducts,
  });

  /// Helper methods
  String get fullName => '$firstName $lastName';

  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  String get formattedDate => TFormatter.formatDateAndTime(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDateAndTime(updatedAt);

  /// Static function to split full name into first and last name.
  static List<String> nameParts(fullName) => fullName.split(" ");

  /// Static function to generate a username from the full name.
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername = "$firstName$lastName"; // Combine first and last name
    String usernameWithPrefix = "cwt_$camelCaseUsername"; // Add "cwt_" prefix
    return usernameWithPrefix;
  }

  /// Static function to create an empty user model.
  static UserModel empty() =>
      UserModel(id: '', email: '', isEmailVerified: false, isProfileActive: false); // Default createdAt to current time

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'pin': pin,
      'profilePicture': profilePicture,
      'role': role.name.toString(),
      'isEmailVerified': isEmailVerified,
      'isProfileActive': isProfileActive,
      'points': points,
      'orderCount': orderCount,
      'deviceToken': deviceToken,
      'reviewedProducts': reviewedProducts,
      'verificationStatus': verificationStatus.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt = DateTime.now(),
    };
  }

  // Factory method to create UserModel from Firestore document snapshot
  factory UserModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel.fromJson(doc.id, data);
  }

  // Static method to create a list of UserModel from QuerySnapshot (for retrieving multiple users)
  static UserModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(doc.id, data);
  }

  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromJson(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      firstName: data.containsKey('firstName') ? data['firstName'] ?? '' : '',
      lastName: data.containsKey('lastName') ? data['lastName'] ?? '' : '',
      userName: data.containsKey('userName') ? data['userName'] ?? '' : '',
      email: data.containsKey('email') ? data['email'] ?? '' : '',
      phoneNumber: data.containsKey('phoneNumber') ? data['phoneNumber'] ?? '' : '',
      pin: data.containsKey('pin') ? data['pin'] ?? '' : '',
      profilePicture: data.containsKey('profilePicture') ? data['profilePicture'] ?? '' : '',
      role: data.containsKey('role')
          ? (data['role'] ?? AppRole.user) == AppRole.admin.name.toString()
              ? AppRole.admin
              : AppRole.user
          : AppRole.user,
      createdAt: data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() ?? DateTime.now() : DateTime.now(),
      updatedAt: data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() ?? DateTime.now() : DateTime.now(),
      // points: data.containsKey('points') ? data['points'] ?? 0 : 0,
      // orderCount: data.containsKey('orderCount') ? data['orderCount'] ?? 0 : 0,
      points: (data['points'] ?? 0) is num ? (data['points'] as num).toInt() : 0,
      orderCount: (data['orderCount'] ?? 0) is num ? (data['orderCount'] as num).toInt() : 0,
      deviceToken: data.containsKey('deviceToken') ? data['deviceToken'] ?? '' : '',
      isEmailVerified: data.containsKey('isEmailVerified') ? data['isEmailVerified'] ?? false : false,
      isProfileActive: data.containsKey('isProfileActive') ? data['isProfileActive'] ?? false : false,
      reviewedProducts: data.containsKey('reviewedProducts') ? List<String>.from(data['reviewedProducts'] ?? []) : null,
      verificationStatus: data.containsKey('verificationStatus')
          ? _mapVerificationStringToEnum(data['verificationStatus'] ?? '')
          : VerificationStatus.pending,
    );
  }

  // Utility to map a role string to the Roles enum
  static VerificationStatus _mapVerificationStringToEnum(String verification) {
    switch (verification) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'submitted':
        return VerificationStatus.submitted;
      case 'underReview':
        return VerificationStatus.underReview;
      default:
        return VerificationStatus.unknown;
    }
  }
}
