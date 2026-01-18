
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../user/models/user_chat_model.dart';
import '../models/doctor_chat_model.dart';

class DoctorChatController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  RxList<DoctorChat> doctorChats = <DoctorChat>[].obs;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isLoading = false.obs;

  Stream<List<DoctorChat>> getDoctorChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('doctor_chats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final chats = <DoctorChat>[];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          if (doc.id.isEmpty) continue;

          String doctorImage = data['doctorImage'] ?? '';
          final doctorId = data['doctorId'] ?? '';

          if (doctorId.isNotEmpty) {
            try {
              final verificationDoc = await _db
                  .collection('doctor_verification_requests')
                  .doc(doctorId)
                  .get();

              if (verificationDoc.exists) {
                final verificationData = verificationDoc.data();
                if (verificationData != null &&
                    verificationData.containsKey('documents')) {
                  final documents = verificationData['documents'];
                  if (documents != null && documents is Map) {
                    final profilePic = documents['profilePicture'];
                    if (profilePic != null && profilePic is String && profilePic.isNotEmpty) {
                      doctorImage = profilePic;
                    }
                  }
                }

                // Fallback to direct profilePicture field if documents not found
                if (doctorImage == (data['doctorImage'] ?? '') &&
                    verificationData != null &&
                    verificationData.containsKey('profilePicture')) {
                  final profilePic = verificationData['profilePicture'];
                  if (profilePic != null && profilePic is String && profilePic.isNotEmpty) {
                    doctorImage = profilePic;
                  }
                }
              }
            } catch (e) {
              // Continue with the stored doctorImage as fallback
            }
          }

          // Create chat with updated doctor image
          final chatData = Map<String, dynamic>.from(data);
          chatData['doctorImage'] = doctorImage;

          final chat = DoctorChat.fromFirestore(chatData, doc.id);
          chats.add(chat);
        } catch (e) {
          // Skip problematic chat documents
        }
      }

      // Sort by last message time descending
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    });
  }

  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    if (chatId.isEmpty) {
      return Stream.value([]);
    }

    try {
      return _db
          .collection('doctor_chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        final msgs = snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id))
            .toList();
        // Sort by timestamp ascending (oldest first)
        msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return msgs;
      });
    } catch (e) {
      print('Error in getChatMessages: $e');
      return Stream.value([]);
    }
  }

  Future<String> startChatWithDoctor({
    required String doctorId,
    required String doctorName,
    required String doctorImage,
  }) async {
    try {
      print('=== Starting Chat Debug ===');

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.uid;
      print('Current user ID: $userId');

      // Check if chat already exists
      final existingChat = await _db
          .collection('doctor_chats')
          .where('userId', isEqualTo: userId)
          .where('doctorId', isEqualTo: doctorId)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        final chatId = existingChat.docs.first.id;

        // Update the doctor image in existing chat
        try {
          final verificationDoc = await _db
              .collection('doctor_verification_requests')
              .doc(doctorId)
              .get();

          if (verificationDoc.exists) {
            final verificationData = verificationDoc.data();
            String updatedImage = doctorImage;

            if (verificationData != null &&
                verificationData.containsKey('documents')) {
              final documents = verificationData['documents'];
              if (documents != null && documents is Map) {
                final profilePic = documents['profilePicture'];
                if (profilePic != null && profilePic is String && profilePic.isNotEmpty) {
                  updatedImage = profilePic;
                }
              }
            }

            if (updatedImage == doctorImage &&
                verificationData != null &&
                verificationData.containsKey('profilePicture')) {
              final profilePic = verificationData['profilePicture'];
              if (profilePic != null && profilePic is String && profilePic.isNotEmpty) {
                updatedImage = profilePic;
              }
            }

            // Update chat with new image
            await _db.collection('doctor_chats').doc(chatId).update({
              'doctorImage': updatedImage,
            });
          }
        } catch (e) {
          // Continue without updating
        }

        return chatId;
      }

      // Fetch doctor's profile picture from doctor_verification_requests
      String fetchedDoctorImage = doctorImage;
      try {
        final verificationDoc = await _db
            .collection('doctor_verification_requests')
            .doc(doctorId)
            .get();

        if (verificationDoc.exists) {
          final verificationData = verificationDoc.data();
          if (verificationData != null &&
              verificationData.containsKey('documents')) {
            final documents = verificationData['documents'];
            if (documents != null && documents is Map) {
              final profilePic = documents['profilePicture'];
              if (profilePic != null && profilePic is String && profilePic.isNotEmpty) {
                fetchedDoctorImage = profilePic;
              }
            }
          }

          // Fallback to direct profilePicture field if documents not found
          if (fetchedDoctorImage == doctorImage &&
              verificationData != null &&
              verificationData.containsKey('profilePicture')) {
            final profilePic = verificationData['profilePicture'];
            if (profilePic != null && profilePic is String && profilePic.isNotEmpty) {
              fetchedDoctorImage = profilePic;
            }
          }
        }
      } catch (e) {
        // Continue with the provided doctorImage as fallback
      }

      // Create new chat
      final chatId = const Uuid().v4();

      final chatData = {
        'userId': userId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImage': fetchedDoctorImage,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('doctor_chats').doc(chatId).set(chatData);

      return chatId;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderName,
  }) async {
    // Validate inputs
    if (chatId.isEmpty) {
      print('Error: chatId is empty in sendMessage');
      throw Exception('Chat ID cannot be empty');
    }

    if (message.trim().isEmpty) {
      print('Error: message is empty in sendMessage');
      throw Exception('Message cannot be empty');
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    print('Sending message to chatId: $chatId');

    try {
      final messageId = const Uuid().v4();

      // Add message to subcollection
      await _db
          .collection('doctor_chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'senderId': userId,
        'senderName': senderName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update last message in chat
      await _db.collection('doctor_chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}