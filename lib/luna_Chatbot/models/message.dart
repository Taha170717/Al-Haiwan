import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sender; // "User" or "Luna"
  final String text;
  final String? imageUrl;
  final DateTime? timestamp;

  Message({
    required this.sender,
    required this.text,
    this.imageUrl,
    this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> m) {
    return Message(
      sender: m['sender'] ?? '',
      text: m['text'] ?? '',
      imageUrl: m['imageUrl'],
      timestamp: m['timestamp'] != null ? (m['timestamp'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
