import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _currentLanguage = 'es';

  String get currentLanguage {
    return _currentLanguage;
  }

  Future<void> updateLanguage(String newLanguage) async {
    _currentLanguage = newLanguage;
    notifyListeners();
    await _storage.write(key: 'language', value: newLanguage);
  }

  Future<void> loadLanguage() async {
    final savedLanguage = await _storage.read(key: 'language');
    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
    }
    notifyListeners();
  }
}

