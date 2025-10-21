import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/doctor_users_chat_controller.dart';
import 'doctor_chat_screen.dart';
import 'doctor_chat_screen_list.dart';

class DoctorUsersChatListScreen extends StatefulWidget {
  const DoctorUsersChatListScreen({Key? key}) : super(key: key);

  @override
  State<DoctorUsersChatListScreen> createState() =>
      _DoctorUsersChatListScreenState();
}

class _DoctorUsersChatListScreenState extends State<DoctorUsersChatListScreen> {
  final DoctorUsersChatController controller =
  Get.put(DoctorUsersChatController());
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontWeight: FontWeight.bold,
            fontSize: screen.width * (isTablet ? 0.04 : 0.06),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screen.width * 0.04),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                controller.updateSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Color(0xFF199A8E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.06),
                  borderSide: BorderSide(color: Color(0xFF199A8E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.06),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screen.width * 0.06),
                  borderSide: BorderSide(color: Color(0xFF199A8E), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screen.width * 0.04,
                  vertical: screen.height * 0.015,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredUsers = controller.getFilteredUsers();

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: screen.width * 0.15,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: screen.height * 0.02),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.02),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final hasUnread = user.unreadCount > 0;

                  return GestureDetector(
                    onTap: () async {
                      try {
                        final chatId = await controller.getChatId(user.id);
                        await controller.markMessagesAsRead(chatId);
                        Get.to(
                              () => DoctorChatScreen(
                            chatId: chatId,
                            doctorName: user.name,
                            doctorImage: user.profileImage,
                          ),
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to open chat: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: screen.height * 0.008,
                        horizontal: screen.width * 0.02,
                      ),
                      padding: EdgeInsets.all(screen.width * 0.03),
                      decoration: BoxDecoration(
                        color: hasUnread
                            ? Color(0xFF199A8E).withOpacity(0.1)
                            : Colors.white,
                        borderRadius:
                        BorderRadius.circular(screen.width * 0.04),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: screen.width * 0.12,
                            height: screen.width * 0.12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF199A8E),
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: user.profileImage.isNotEmpty
                                  ? Image.network(
                                user.profileImage,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.person,
                                        color: Colors.grey),
                                  );
                                },
                              )
                                  : Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.person,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(width: screen.width * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: TextStyle(
                                          color: Color(0xFF199A8E),
                                          fontWeight: hasUnread
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: screen.width *
                                              (isTablet ? 0.025 : 0.035),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(user.lastMessageTime),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screen.width *
                                            (isTablet ? 0.02 : 0.025),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screen.height * 0.005),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.lastMessage.isNotEmpty
                                            ? user.lastMessage
                                            : 'No messages yet',
                                        style: TextStyle(
                                          color: hasUnread
                                              ? Colors.black87
                                              : Colors.grey,
                                          fontSize: screen.width *
                                              (isTablet ? 0.02 : 0.03),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasUnread)
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: screen.width * 0.02),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screen.width * 0.02,
                                          vertical: screen.height * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF199A8E),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${user.unreadCount}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screen.width *
                                                (isTablet ? 0.018 : 0.025),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate =
    DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
