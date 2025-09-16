import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // 🔑 Paste your Gemini API Key here
  static const String _apiKey = "AIzaSyDDUCQvxDZnKzirwc-gq4r5PSf9ToLQphw";

  // Choose your model (you can switch to gemini-2.0-flash, gemini-1.5-pro, etc.)
  static const String _model = 'gemini-1.5-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  /// Generate text or multimodal response
  static Future<String> generate(String prompt, {String? base64Image}) async {
    final List parts = [];

    if (base64Image != null) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Image,
        }
      });
    }

    parts.add({'text': prompt});

    final body = {
      'contents': [
        {
          'role': 'user',
          'parts': parts,
        }
      ],
      'generation_config': {
        'temperature': 0.2,
        'max_output_tokens': 1024,
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': _apiKey,
    };

    final resp = await http.post(Uri.parse(_endpoint),
        headers: headers, body: jsonEncode(body));

    if (resp.statusCode != 200) {
      throw Exception('Gemini API error ${resp.statusCode}: ${resp.body}');
    }

    final Map data = jsonDecode(resp.body);

    try {
      final candidates = data['candidates'] as List<dynamic>? ?? [];
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List<dynamic>? ?? [];
        for (final p in parts) {
          if (p is Map && p.containsKey('text')) {
            return p['text'] as String;
          }
        }
      }
      if (data.containsKey('text')) return data['text'] as String;
    } catch (_) {}

    throw Exception('Could not parse Gemini response: ${resp.body}');
  }
}
