class ParticipantModel {
  String userId;
  String name;
  String profileImageURL;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.profileImageURL,
  });

  // Convert Participant model to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'profileImageURL': profileImageURL,
    };
  }

  // Create Participant model from Firestore map
  static ParticipantModel fromFirestore(Map<String, dynamic> data) {
    return ParticipantModel(
      userId: data.containsKey('userId') ? data['userId'] : '',
      name: data.containsKey('name') ? data['name'] : 'Unknown',
      profileImageURL: data.containsKey('profileImageURL') ? data['profileImageURL'] : '',
    );
  }
}
