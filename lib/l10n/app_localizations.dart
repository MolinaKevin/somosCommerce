import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<void> load() async {
    print('Cargando localizaciones para ${locale.languageCode}');
    TranslationService translationService = TranslationService();
    try {
      _localizedStrings = await translationService.fetchTranslations(locale.languageCode);
      print('Traducciones cargadas: $_localizedStrings');
    } catch (e) {
      print('Error al cargar las traducciones: $e');
      _localizedStrings = {};
    }
  }

  dynamic _getNestedValue(Map<String, dynamic> map, List<String> keys) {
    dynamic value = map;
    for (String key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return null;
      }
    }
    return value;
  }

  String? translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _getNestedValue(_localizedStrings, keys);
    if (value is String) {
      return value;
    } else {
      print('Translation not found for key: $key');
      return null;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
