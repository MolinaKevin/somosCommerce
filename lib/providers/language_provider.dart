import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageProvider with ChangeNotifier {
  // Almacenamiento seguro para guardar el idioma seleccionado
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _currentLanguage = 'es'; // Idioma por defecto

  // Getter para obtener el idioma actual
  String get currentLanguage => _currentLanguage;

  // Método para actualizar el idioma
  Future<void> updateLanguage(String newLanguage) async {
    _currentLanguage = newLanguage;
    notifyListeners();
    await _storage.write(key: 'language', value: newLanguage);
  }

  // Método para cargar el idioma desde el almacenamiento
  Future<void> loadLanguage() async {
    final savedLanguage = await _storage.read(key: 'language');
    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
      notifyListeners();
    }
  }
}
