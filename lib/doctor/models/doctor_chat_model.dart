import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorChat {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  DoctorChat({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory DoctorChat.fromFirestore(Map<String, dynamic> data, String id) {
    return DoctorChat(
      id: id,
      userId: data['userId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Doctor',
      doctorImage: data['doctorImage'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
