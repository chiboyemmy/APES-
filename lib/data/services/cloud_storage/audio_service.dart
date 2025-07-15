import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CloudAudioStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save audio file to Firebase and store the URL in Firestore
  Future<String> saveAudio(String chatId, String senderId, String path) async {
    try {
      final File file = File(path);
      final storageRef = _storage.ref().child('audio/$chatId/${DateTime.now().millisecondsSinceEpoch}.m4a');
      UploadTask uploadTask = storageRef.putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;
      final audioUrl = await taskSnapshot.ref.getDownloadURL();
      return audioUrl;
    } catch (e) {
      throw Exception('Error uploading audio file: $e');
    }
  }

  // Fetch audio file by URL
  Future<String> fetchAudio(String audioUrl) async {
    try {
      final ref = _storage.refFromURL(audioUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error fetching audio file: $e');
    }
  }
}
