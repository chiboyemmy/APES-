import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';



class AddressModel {
  String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final DateTime? createdAt;
  bool selectedAddress;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.createdAt,
    this.selectedAddress = true,
  });

  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  static AddressModel empty() =>
      AddressModel(id: '', name: '', phoneNumber: '', street: '', city: '', state: '', postalCode: '', country: '');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'createdAt': DateTime.now(),
      'selectedAddress': selectedAddress,
    };
  }

  /// Create an AddressModel from a JSON Map
  factory AddressModel.fromJson(String id, Map<String, dynamic> data) {

    return AddressModel(
      id: id,
      name: data.containsKey('name') ? data['name']  ?? '' : '',
      phoneNumber: data.containsKey('phoneNumber') ? data['phoneNumber']  ?? '' : '',
      street: data.containsKey('street') ? data['street']  ?? '' : '',
      city: data.containsKey('city') ? data['city']  ?? '' : '',
      state: data.containsKey('state') ? data['state']  ?? '' : '',
      postalCode: data.containsKey('postalCode') ? data['postalCode']  ?? '' : '',
      country: data.containsKey('country') ? data['country']  ?? '' : '',
      selectedAddress: data.containsKey('selectedAddress') ? data['selectedAddress'] as bool : false,
      createdAt: data.containsKey('createdAt') ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  /// Factory method to create AttributeModel from Firestore document snapshot
  factory AddressModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AddressModel.fromJson(doc.id, data);
  }

  /// Factory method to create a list of AttributeModel from QuerySnapshot (for retrieving multiple attributes)
  static AddressModel fromQuerySnapshot(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel.fromJson(doc.id, data);
  }

  @override
  String toString() {
    return '$street, $city, $state $postalCode, $country';
  }
}
