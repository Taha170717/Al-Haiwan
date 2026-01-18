import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static const String _model = 'openai/gpt-oss-20b';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> generate(String prompt, {String? base64Image}) async {
    // Ensure dotenv is loaded and read the API key safely.
    String apiKey = '';
    try {
      apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    } catch (_) {
      // Not initialized; try to load .env then read
      try {
        await dotenv.load();
      } catch (_) {
        // ignore
      }
      try {
        apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      } catch (_) {
        apiKey = '';
      }
    }

    if (apiKey.isEmpty) {
      throw Exception('Groq API key not configured. Add GROQ_API_KEY to .env or set environment variables.');
    }

    final List<Map<String, dynamic>> messages = [];

    messages.add({
      'role': 'system',
      'content':
          'You are Luna, an AI Animal Care Health Chatbot specialist. Your expertise includes veterinary advice, pet health concerns, animal behavior, nutrition guidance, emergency care instructions, and general pet wellness. Always provide helpful, accurate, and caring responses about animal health. When users ask about serious health issues, always recommend consulting with a veterinarian. Be friendly, knowledgeable, and show genuine care for animals and their well-being. Start responses naturally without always saying "I am Luna" unless specifically asked who you are.'
    });

    if (base64Image != null) {
      messages.add({
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': prompt,
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
            },
          },
        ],
      });
    } else {
      messages.add({
        'role': 'user',
        'content': prompt,
      });
    }

    final body = {
      'model': _model,
      'messages': messages,
      'temperature': 0.2,
      'max_tokens': 1024,
      'top_p': 1,
      'stream': false,
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Groq API error ${resp.statusCode}: ${resp.body}');
    }

    final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;

    // Try multiple common response shapes defensively
    try {
      // Try OpenAI-like chat completions
      if (data.containsKey('choices') && data['choices'] is List && (data['choices'] as List).isNotEmpty) {
        final first = (data['choices'] as List).first;
        if (first is Map && first.containsKey('message')) {
          final message = first['message'];
          if (message is Map) {
            // 'content' may be string or structured
            final content = message['content'];
            if (content is String) return content;
            if (content is List && content.isNotEmpty) return content.join('\n');
          }
        }
        // fallback: if 'choices'[0]['text'] exists
        if (first is Map && first['text'] is String) return first['text'] as String;
      }

      // Some providers return 'message' at top level
      if (data['message'] is String) return data['message'] as String;

      // last-resort: stringify top-level content
      return data.toString();
    } catch (e) {
      throw Exception('Could not parse Groq response: ${resp.body}');
    }
  }
}
