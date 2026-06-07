// lib/services/translation_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class TranslationService {
  static final _translator = GoogleTranslator();

  // ── Translate a single string to Malayalam, with SharedPreferences cache ──
  static Future<String> toMalayalam(String text) async {
    if (text.trim().isEmpty) return text;

    final cacheKey = 'trans_ml_${text.hashCode}';

    try {
      final prefs = await SharedPreferences.getInstance();

      // Return cached translation if available
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) return cached;

      // Call Google Translate (en → ml)
      final result = await _translator.translate(text, from: 'en', to: 'ml');
      final translated = result.text;

      // Cache the result so we don't re-translate on every screen open
      await prefs.setString(cacheKey, translated);

      return translated;
    } catch (e) {
      // If translation fails for any reason, fall back to original English text
      print('Translation error: $e');
      return text;
    }
  }

  // ── Translate a map of disease fields all at once ──
  static Future<Map<String, String>> translateDiseaseFields({
    required String description,
    required String recommendation,
    required String skincare,
  }) async {
    // Run all three translations in parallel for speed
    final results = await Future.wait([
      toMalayalam(description),
      toMalayalam(recommendation),
      toMalayalam(skincare),
    ]);

    return {
      'description': results[0],
      'recommendation': results[1],
      'skincare': results[2],
    };
  }

  // ── Clear all cached translations (e.g. useful after admin edits disease) ──
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('trans_ml_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}