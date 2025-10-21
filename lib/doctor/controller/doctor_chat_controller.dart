import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
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
      print('Error: User not authenticated in getDoctorChats');
      return Stream.value([]);
    }

    print('Getting doctor chats for user: $userId');

    return _db
        .collection('doctor_chats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      print('Found ${snapshot.docs.length} chat documents');

      final chats = <DoctorChat>[];

      for (var doc in snapshot.docs) {
        try {
          print('Processing chat document ID: ${doc.id}');
          print('Document data: ${doc.data()}');

          if (doc.id.isEmpty) {
            print('Warning: Document has empty ID, skipping');
            continue;
          }

          final chat = DoctorChat.fromFirestore(doc.data(), doc.id);
          chats.add(chat);
          print('Successfully created chat object for: ${chat.doctorName}');
        } catch (e) {
          print('Error processing chat document ${doc.id}: $e');
        }
      }

      // Sort by last message time descending
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      print('Returning ${chats.length} processed chats');
      return chats;
    });
  }

  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    // Validate chatId
    if (chatId.isEmpty) {
      print('Error: chatId is empty in getChatMessages');
      return Stream.value([]);
    }

    print('Getting messages for chatId: $chatId');

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
      print('Current user email: ${currentUser.email}');
      print('Doctor ID: $doctorId');
      print('Doctor name: $doctorName');

      print(
          'Checking for existing chat between user: $userId and doctor: $doctorId');

      // Check if chat already exists
      final existingChat = await _db
          .collection('doctor_chats')
          .where('userId', isEqualTo: userId)
          .where('doctorId', isEqualTo: doctorId)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        print('Existing chat found: ${existingChat.docs.first.id}');
        return existingChat.docs.first.id;
      }

      print('No existing chat found. Creating new chat...');

      // Create new chat
      final chatId = const Uuid().v4();
      print('Generated chat ID: $chatId');

      final chatData = {
        'userId': userId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImage': doctorImage,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print('Chat data to be saved: $chatData');

      await _db.collection('doctor_chats').doc(chatId).set(chatData);

      print('Chat created successfully with ID: $chatId');
      print('=== Chat Debug Complete ===');
      return chatId;
    } catch (e, stackTrace) {
      print('Error in startChatWithDoctor: $e');
      print('Stack trace: $stackTrace');
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
