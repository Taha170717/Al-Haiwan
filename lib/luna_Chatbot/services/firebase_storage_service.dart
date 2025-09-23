import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStorageService {
  static Future<String> uploadImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final path = 'users/${user.uid}/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);

    final task = await ref.putFile(file);
    final url = await task.ref.getDownloadURL();
    return url;
  }
}
