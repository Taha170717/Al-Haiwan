import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../user/models/user_chat_model.dart';
import '../models/doctor_chat_model.dart';

class DoctorUsersChatController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  RxList<UserChatModel> userChats = <UserChatModel>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserChats();
  }

  void loadUserChats() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) {
      print('Error: Doctor not authenticated');
      return;
    }

    print('Loading chats for doctor: $doctorId');
    isLoading.value = true;

    try {
      _db
          .collection('doctor_chats')
          .where('doctorId', isEqualTo: doctorId)
          .snapshots()
          .listen((snapshot) async {
        print('Found ${snapshot.docs.length} chat documents');

        final List<UserChatModel> chats = [];

        for (var doc in snapshot.docs) {
          try {
            final chatData = doc.data();
            final userId = chatData['userId'] as String?;

            if (userId == null || userId.isEmpty) {
              print('Warning: Chat ${doc.id} has no userId');
              continue;
            }

            print('Processing chat for user: $userId');

            // Fetch user data from users collection
            final userDoc = await _db.collection('users').doc(userId).get();

            if (!userDoc.exists) {
              print('Warning: User $userId not found in users collection');
              continue;
            }

            final userData = userDoc.data() ?? {};
            print('User data: $userData');

            // Create UserChatModel with combined data
            final userChat = UserChatModel(
              id: userId,
              name:
                  userData['name'] ?? userData['displayName'] ?? 'Unknown User',
              email: userData['email'] ?? '',
              profileImage:
                  userData['profileImageUrl'] ?? userData['imageUrl'] ?? '',
              lastMessage: chatData['lastMessage'] ?? '',
              lastMessageTime:
                  (chatData['lastMessageTime'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
              unreadCount: chatData['unreadCount'] ?? 0,
            );

            chats.add(userChat);
            print('Added chat for user: ${userChat.name}');
          } catch (e) {
            print('Error processing chat document ${doc.id}: $e');
          }
        }

        // Sort by last message time descending
        chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        userChats.value = chats;
        isLoading.value = false;

        print('Loaded ${chats.length} user chats');
      });
    } catch (e) {
      print('Error loading user chats: $e');
      isLoading.value = false;
    }
  }

  List<UserChatModel> getFilteredUsers() {
    if (searchQuery.value.isEmpty) {
      return userChats;
    }
    return userChats
        .where((user) =>
    user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        user.email.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<String> getChatId(String userId) async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) throw Exception('Doctor not authenticated');

    print('Getting chat ID for doctor: $doctorId, user: $userId');

    final chatDoc = await _db
        .collection('doctor_chats')
        .where('doctorId', isEqualTo: doctorId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (chatDoc.docs.isNotEmpty) {
      final chatId = chatDoc.docs.first.id;
      print('Found chat ID: $chatId');
      return chatId;
    }

    print('Chat not found for doctor: $doctorId, user: $userId');
    throw Exception('Chat not found');
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return;

    try {
      print('Marking messages as read for chat: $chatId');

      final messagesSnapshot = await _db
          .collection('doctor_chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();

      print('Found ${messagesSnapshot.docs.length} unread messages');

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Reset unread count
      await _db.collection('doctor_chats').doc(chatId).update({
        'unreadCount': 0,
      });

      print('Messages marked as read successfully');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}
