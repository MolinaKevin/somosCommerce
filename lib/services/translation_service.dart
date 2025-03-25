import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class TranslationService {
  Future<Map<String, dynamic>> fetchTranslations(String language) async {
    final String jsonString = await rootBundle.loadString('lib/mocking/lang/$language.json');
    final Map<String, dynamic> translations = jsonDecode(jsonString);
    return translations;
  }

  Future<List<Locale>> fetchAvailableLocales() async {
    final List<String> supportedLanguages = ['en', 'es', 'de'];
    return supportedLanguages.map((lang) => Locale(lang)).toList();
  }
}
