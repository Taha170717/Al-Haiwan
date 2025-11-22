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
    if (doctorId == null) return;

    isLoading.value = true;

    try {
      _db
          .collection('doctor_chats')
          .where('doctorId', isEqualTo: doctorId)
          .snapshots()
          .listen((snapshot) async {
        final List<UserChatModel> chats = [];

        for (var doc in snapshot.docs) {
          try {
            final chatData = doc.data();
            final userId = chatData['userId'] as String?;

            if (userId == null || userId.isEmpty) continue;

            // Fetch user data from users collection
            final userDoc = await _db.collection('users').doc(userId).get();

            if (!userDoc.exists) continue;

            final userData = userDoc.data() ?? {};

            // Fetch profile image from doctor_verification_requests
            String profileImage = '';
            try {
              final verificationDoc = await _db
                  .collection('doctor_verification_requests')
                  .doc(userId)
                  .get();

              if (verificationDoc.exists) {
                final verificationData = verificationDoc.data();
                if (verificationData != null &&
                    verificationData.containsKey('documents')) {
                  final documents = verificationData['documents'];
                  if (documents != null && documents is Map) {
                    profileImage =
                        documents['profilePicture']?.toString() ?? '';
                  }
                }
                
                // Fallback to direct profilePicture field if documents not found
                if (profileImage.isEmpty &&
                    verificationData != null &&
                    verificationData.containsKey('profilePicture')) {
                  profileImage = verificationData['profilePicture']?.toString() ?? '';
                }
              }
            } catch (e) {
              // Continue with fallback
            }

            // Fallback to users collection profileImageUrl if verification not found
            if (profileImage.isEmpty) {
              profileImage = userData['profileImageUrl'] ?? userData['imageUrl'] ?? '';
            }

            // Create UserChatModel with combined data
            final userChat = UserChatModel(
              id: userId,
              name:
                  userData['name'] ?? userData['displayName'] ?? 'Unknown User',
              email: userData['email'] ?? '',
              profileImage: profileImage,
              lastMessage: chatData['lastMessage'] ?? '',
              lastMessageTime:
                  (chatData['lastMessageTime'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
              unreadCount: chatData['unreadCount'] ?? 0,
            );

            chats.add(userChat);
          } catch (e) {
            // Skip problematic chat documents
          }
        }

        // Sort by last message time descending
        chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        userChats.value = chats;
        isLoading.value = false;
      });
    } catch (e) {
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

    final chatDoc = await _db
        .collection('doctor_chats')
        .where('doctorId', isEqualTo: doctorId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (chatDoc.docs.isNotEmpty) {
      return chatDoc.docs.first.id;
    }

    throw Exception('Chat not found');
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return;

    try {
      final messagesSnapshot = await _db
          .collection('doctor_chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Reset unread count
      await _db.collection('doctor_chats').doc(chatId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      // Handle error silently
    }
  }
}
