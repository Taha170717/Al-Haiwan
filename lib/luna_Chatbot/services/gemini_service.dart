import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String _model = 'openai/gpt-oss-20b';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> generate(String prompt, {String? base64Image}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Groq API key not found in environment variables');
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
      'Authorization': 'Bearer $_apiKey',
    };

    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Groq API error ${resp.statusCode}: ${resp.body}');
    }

    final Map data = jsonDecode(resp.body);

    try {
      final choices = data['choices'] as List<dynamic>? ?? [];
      if (choices.isNotEmpty) {
        final message = choices[0]['message'];
        if (message != null && message['content'] != null) {
          return message['content'] as String;
        }
      }
    } catch (e) {
      throw Exception('Could not parse Groq response: ${resp.body}');
    }

    throw Exception('Could not parse Groq response: ${resp.body}');
  }
}
