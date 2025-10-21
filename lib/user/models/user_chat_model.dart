import 'package:cloud_firestore/cloud_firestore.dart';

class UserChatModel {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  UserChatModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory UserChatModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserChatModel(
      id: id,
      name: data['name'] ?? 'User',
      email: data['email'] ?? '',
      profileImage: data['profileImage'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }
}
