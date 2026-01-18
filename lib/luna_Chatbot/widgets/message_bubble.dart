import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onSpeak;
  final bool isSpeaking;

  const ChatBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender.toLowerCase() == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) // AI Avatar with image-like design
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF8F00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/lunalogo.png',
                        // Update with your asset path
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isSpeaking)
                    Positioned(
                      right: 4,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

            Flexible(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xFFFFA726)
                      : isSpeaking
                          ? const Color(0xFFFFF3E0) // Highlighted when speaking
                          : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: isSpeaking && !isUser
                      ? Border.all(
                          color: const Color(0xFFFFA726),
                          width: 2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isSpeaking && !isUser
                          ? const Color(0xFFFFA726).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      spreadRadius: isSpeaking && !isUser ? 2 : 1,
                      blurRadius: isSpeaking && !isUser ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.imageUrl!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    // Clean Speaker Button for Luna
                    if (!isUser)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (onSpeak != null) {
                                  onSpeak!();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSpeaking
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFFF5252),
                                            Color(0xFFD32F2F)
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFFFA726),
                                            Color(0xFFFF8F00)
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isSpeaking
                                              ? Colors.red
                                              : const Color(0xFFFFA726))
                                          .withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSpeaking ? Icons.stop : Icons.volume_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isSpeaking ? 'Stop' : 'Listen',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isSpeaking) ...[
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (isUser) // User Avatar with image-like design
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 8, bottom: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/user1.png', // Update with your asset path
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
