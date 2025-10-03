import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/drawer_widget.dart';
import '../services/firebase_storage_service.dart';
import '../services/gemini_service.dart'; // Updated import
import '../services/chat_service.dart'; // Firestore wrapper

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Message> messages = [];
  File? _selectedImage;
  bool _loading = false;
  final FocusNode _focusNode = FocusNode();
  String? _currentSessionId;
  User? _user;

  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';
  bool _isSpeaking = false;
  String? _currentSpeakingMessageId;
  Timer? _ttsTimeout;

  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initUserAndChat();
    _initTTS();
  }

  /// Ensure user exists (anonymous sign-in if needed)
  Future<void> _initUserAndChat() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    _user = auth.currentUser;
    await _startNewChat();
  }

  Future<void> _startNewChat() async {
    if (_user == null) return;

    _currentSessionId = await _chatService.startNewSession();
    messages.clear();

    const greeting =
        "Hi! I'm Luna, your Animal Care Health Assistant! 🐾 How can I help you with your pet's health and well-being today?";
    messages.add(Message(sender: 'Luna', text: greeting));

    await _chatService.saveMessage(_currentSessionId!, greeting, "bot");

    setState(() {});
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img != null) setState(() => _selectedImage = File(img.path));
  }

  void _startListening() async {
    final available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'notListening') setState(() => _isListening = false);
      },
      onError: (val) => setState(() => _isListening = false),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() => _spokenText = val.recognizedWords),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _toggleSpeak(String text, String messageId) async {
    try {
      if (_isSpeaking && _currentSpeakingMessageId == messageId) {
        // AGGRESSIVE STOP - try multiple methods
        print('Stopping TTS aggressively...');

        // Cancel any timer
        _ttsTimeout?.cancel();

        // Try to stop TTS
        await _tts.stop();

        // Force state update immediately
        setState(() {
          _isSpeaking = false;
          _currentSpeakingMessageId = null;
        });

        // Double-check with a small delay
        Future.delayed(Duration(milliseconds: 100), () async {
          if (mounted) {
            await _tts.stop(); // Try again
            setState(() {
              _isSpeaking = false;
              _currentSpeakingMessageId = null;
            });
          }
        });

        print('TTS stopped successfully');
      } else {
        // Stop any current speech first
        if (_isSpeaking) {
          _ttsTimeout?.cancel();
          await _tts.stop();
          setState(() {
            _isSpeaking = false;
            _currentSpeakingMessageId = null;
          });
          // Small delay to ensure stop is processed
          await Future.delayed(Duration(milliseconds: 200));
        }

        print('Starting TTS...');
        setState(() {
          _isSpeaking = true;
          _currentSpeakingMessageId = messageId;
        });

        final result = await _tts.speak(text);
        print('TTS speak initiated with result: $result');

        // Add a timer-based backup mechanism
        _ttsTimeout?.cancel();
        _ttsTimeout = Timer(Duration(seconds: 30), () {
          if (_isSpeaking && mounted) {
            print('TTS timeout - force stopping');
            _tts.stop();
            setState(() {
              _isSpeaking = false;
              _currentSpeakingMessageId = null;
            });
          }
        });

        // Note: Don't reset state here as completion handler will do it
      }
    } catch (e) {
      print('Error in TTS: $e');
      _ttsTimeout?.cancel();
      setState(() {
        _isSpeaking = false;
        _currentSpeakingMessageId = null;
      });
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _focusNode.dispose();
    _ttsTimeout?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage(String userText) async {
    if (_currentSessionId == null ||
        (userText.trim().isEmpty && _selectedImage == null)) return;

    setState(() {
      messages.add(Message(sender: 'User', text: userText, imageUrl: null));
      _loading = true;
    });

    // Handle image upload + base64 for Gemini
    String? storageImageUrl;
    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      const maxBytes = 20 * 1024 * 1024; // 20MB
      if (bytes.length > maxBytes) {
        await _chatService.saveMessage(
          _currentSessionId!,
          "Image too large to analyze (limit ~20MB).",
          "bot",
        );
        setState(() {
          _loading = false;
          _selectedImage = null;
        });
        return;
      }
      base64Image = base64Encode(bytes);
      storageImageUrl =
      await FirebaseStorageService.uploadImage(_selectedImage!);
    }

    // Save User message to Firestore
    await _chatService.saveMessage(
      _currentSessionId!,
      userText,
      "user",
      imageUrl: storageImageUrl,
    );

    try {
      final reply = await GroqService.generate(
        userText,
        base64Image: base64Image,
      );

      setState(() {
        messages.add(Message(sender: 'Luna', text: reply));
      });

      await _chatService.saveMessage(_currentSessionId!, reply, "bot");

      // Removed auto speak AI reply
    } catch (e) {
      final err = 'Error contacting AI: $e';
      setState(() {
        messages.add(Message(sender: 'Luna', text: err));
      });
      await _chatService.saveMessage(_currentSessionId!, err, "bot");
    } finally {
      setState(() {
        _loading = false;
        _selectedImage = null;
        _spokenText = '';
      });
    }
  }

  /// Initialize TTS with proper configuration
  Future<void> _initTTS() async {
    try {
      // Check if TTS is available
      final isAvailable = await _tts.isLanguageAvailable("en-US");
      if (!isAvailable) {
        print('TTS en-US language not available');
      }

      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      // Add TTS completion handler
      _tts.setCompletionHandler(() {
        print('TTS completion handler called');
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentSpeakingMessageId = null;
          });
        }
        _ttsTimeout?.cancel();
      });

      // Add error handler
      _tts.setErrorHandler((message) {
        print('TTS Error: $message');
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentSpeakingMessageId = null;
          });
        }
        _ttsTimeout?.cancel();
      });

      // Add start handler
      _tts.setStartHandler(() {
        print('TTS started speaking');
      });

      // Add cancel handler (for when stop is called)
      _tts.setCancelHandler(() {
        print('TTS cancelled/stopped');
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _currentSpeakingMessageId = null;
          });
        }
        _ttsTimeout?.cancel();
      });
    } catch (e) {
      print('TTS Initialization Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: LunaDrawer(onNewChat: _startNewChat),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFA726)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFA726)),
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF8F00)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/luna.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Luna - Animal Care Health Chatbot',
              style: TextStyle(
                color: Color(0xFFFFA726),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFFFA726)),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Simplified background to clean white
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Welcome to Luna 🐾',
                      style: TextStyle(
                        color: Color(0xFFFFA726),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trusted Animal Care Health Assistant',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _currentSessionId == null
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFA726)))
                    : StreamBuilder<QuerySnapshot>(
                  stream: _chatService.getMessages(_currentSessionId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(color: Color(0xFFFFA726)));
                    }

                    final docs = snapshot.data!.docs;
                    final chatMessages = docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return Message(
                        sender: data['sender'] ?? '',
                        text: data['text'] ?? '',
                        imageUrl: data['imageUrl'],
                      );
                    }).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      reverse: false,
                      itemCount: chatMessages.length,
                      itemBuilder: (ctx, i) {
                        final m = chatMessages[i];
                              final messageId = docs[i]
                                  .id; // Use Firestore document ID as unique identifier
                              return ChatBubble(
                                message: m,
                                onSpeak:
                                    (!m.sender.toLowerCase().contains('user'))
                                        ? () => _toggleSpeak(m.text, messageId)
                                        : null,
                                isSpeaking: _isSpeaking &&
                                    _currentSpeakingMessageId == messageId,
                              );
                            },
                          );
                        },
                      ),
              ),
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, height: 80, width: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Image selected for analysis',
                          style: TextStyle(color: Color(0xFFFFA726), fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ],
                  ),
                ),
              if (_loading)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: const LinearProgressIndicator(
                    color: Color(0xFFFFA726),
                    backgroundColor: Color(0xFFFFF8E1),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16), // Increased padding for better spacing
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.image_outlined, color: Color(0xFFFFA726)),
                        onPressed: _pickImage,
                        tooltip: 'Add Image',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red.withOpacity(0.1) : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none_outlined,
                          color: _isListening ? Colors.red : const Color(0xFFFFA726),
                        ),
                        onPressed: _isListening ? _stopListening : _startListening,
                        tooltip: _isListening ? 'Stop Recording' : 'Voice Input',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MessageInput(
                        onSend: _sendMessage,
                        onImagePick: _pickImage,
                        focusNode: _focusNode,
                        initialText: _spokenText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
