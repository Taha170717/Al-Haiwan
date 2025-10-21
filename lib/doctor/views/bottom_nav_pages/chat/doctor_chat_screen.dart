import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controller/doctor_chat_controller.dart';
import '../../../models/doctor_chat_model.dart';


class DoctorChatScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorImage;

  const DoctorChatScreen({
    required this.chatId,
    required this.doctorName,
    required this.doctorImage,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final DoctorChatController chatController = Get.put(DoctorChatController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width > 600;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF199A8E)),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              width: screen.width * 0.1,
              height: screen.width * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF199A8E), width: 1),
              ),
              child: ClipOval(
                child: widget.doctorImage.isNotEmpty
                    ? Image.network(
                  widget.doctorImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person, color: Colors.grey),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: screen.width * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: TextStyle(
                    color: Color(0xFF199A8E),
                    fontWeight: FontWeight.bold,
                    fontSize: screen.width * (isTablet ? 0.03 : 0.04),
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: screen.width * (isTablet ? 0.02 : 0.03),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatController.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF199A8E)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading messages'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(screen.width * 0.04),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == currentUserId;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: screen.height * 0.01,
                          left: isCurrentUser ? screen.width * 0.2 : 0,
                          right: isCurrentUser ? 0 : screen.width * 0.2,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screen.width * 0.04,
                          vertical: screen.height * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Color(0xFF199A8E)
                              : Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(
                            screen.width * 0.04,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isCurrentUser
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: screen.width * (isTablet ? 0.025 : 0.035),
                              ),
                            ),
                            SizedBox(height: screen.height * 0.005),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: isCurrentUser
                                    ? Colors.white70
                                    : Colors.grey,
                                fontSize: screen.width * (isTablet ? 0.02 : 0.025),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(screen.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
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
                    maxLines: null,
                  ),
                ),
                SizedBox(width: screen.width * 0.02),
                GestureDetector(
                  onTap: () async {
                    if (messageController.text.trim().isNotEmpty) {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      await chatController.sendMessage(
                        chatId: widget.chatId,
                        message: messageController.text.trim(),
                        senderName: currentUser?.displayName ?? 'User',
                      );
                      messageController.clear();
                      _scrollToBottom();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(screen.width * 0.03),
                    decoration: BoxDecoration(
                      color: Color(0xFF199A8E),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: screen.width * 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
