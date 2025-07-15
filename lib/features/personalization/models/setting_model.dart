import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final String? id;
  double taxRate;
  double shippingCost;
  double? freeShippingThreshold;
  String appName;
  String appLogo;

  // Point-based system variables
  double pointsPerPurchase;   // Points earned per dollar spent
  double pointsPerReview;
  double pointsPerRating;
  double pointsToDollarConversion; // How many points equal $1
  bool isTaxShippingEnabled;
  bool isPointBaseEnabled;

  /// Constructor for SettingModel.
  SettingsModel({
    this.id,
    this.taxRate = 0.0,
    this.shippingCost = 0.0,
    this.freeShippingThreshold,
    this.appName = '',
    this.appLogo = '',
    this.pointsPerPurchase = 0.0,
    this.pointsPerReview = 0.0,
    this.pointsPerRating = 0.0,
    this.pointsToDollarConversion = 100.0,  // Default: 100 points = $1
    this.isTaxShippingEnabled = true,
    this.isPointBaseEnabled = true,
  });

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'taxRate': taxRate,
      'shippingCost': shippingCost,
      'freeShippingThreshold': freeShippingThreshold,
      'appName': appName,
      'appLogo': appLogo,
      'pointsPerPurchase': pointsPerPurchase,
      'pointsPerReview': pointsPerReview,
      'pointsPerRating': pointsPerRating,
      'pointsToDollarConversion': pointsToDollarConversion,  // New variable
      'isTaxShippingEnabled': isTaxShippingEnabled,
      'isPointBaseEnabled': isPointBaseEnabled,

    };
  }

  /// Factory method to create a SettingModel from a Firebase document snapshot.
  factory SettingsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return SettingsModel(
        id: document.id,
        taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
        shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
        freeShippingThreshold: (data['freeShippingThreshold'] as num?)?.toDouble() ?? 0.0,
        appName: data.containsKey('appName') ? data['appName'] ?? '' : '',
        appLogo: data.containsKey('appLogo') ? data['appLogo'] ?? '' : '',
        pointsPerPurchase: (data['pointsPerPurchase'] as num?)?.toDouble() ?? 0.0,
        pointsPerReview: (data['pointsPerReview'] as num?)?.toDouble() ?? 0.0,
        pointsPerRating: (data['pointsPerRating'] as num?)?.toDouble() ?? 0.0,
        pointsToDollarConversion: (data['pointsToDollarConversion'] as num?)?.toDouble() ?? 100.0,  // New conversion
        isTaxShippingEnabled: data.containsKey('isTaxShippingEnabled') ? data['isTaxShippingEnabled'] as bool : false,
        isPointBaseEnabled: data.containsKey('isPointBaseEnabled') ? data['isPointBaseEnabled'] as bool : false,
      );
    } else {
      return SettingsModel();
    }
  }
}

