import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onImagePick;
  final FocusNode? focusNode;
  final String initialText;

  const MessageInput({
    super.key,
    required this.onSend,
    required this.onImagePick,
    this.focusNode,
    this.initialText = '',
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) _controller.text = widget.initialText;
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text field when speech-to-text provides new text
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText.isNotEmpty) {
      _controller.text = widget.initialText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFFFA726).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: widget.focusNode,
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ask Luna about your animal...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (val) => _send(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _send,
              tooltip: 'Send Message',
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    // Remove focus to hide keyboard after sending
    widget.focusNode?.unfocus();
  }
}
