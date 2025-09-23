// chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> startNewSession() async {
    final uid = _auth.currentUser!.uid;
    final sessionId = const Uuid().v4();

    await _db.collection('chatbot_sessions').doc(sessionId).set({
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return sessionId;
  }

  Future<void> saveMessage(String sessionId, String text, String sender,
      {String? imageUrl}) async {
    final uid = _auth.currentUser!.uid;

    await _db
        .collection('chatbot_sessions')
        .doc(sessionId)
        .collection('messages')
        .add({
      'userId': uid,
      'text': text,
      'sender': sender, // "user" or "bot"
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Make sure you order by timestamp
  Stream<QuerySnapshot> getMessages(String sessionId) {
    return _db
        .collection('chatbot_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
