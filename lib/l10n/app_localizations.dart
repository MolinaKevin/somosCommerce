import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, dynamic> _localizedStrings = {};

  Future<void> load() async {
    print('Cargando localizaciones para ${locale.languageCode}');
    String jsonString = await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap;
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
      print('Translating key: $key, value: $value');
      return value;
    } else {
      print('Translation not found for key: $key');
      return null;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

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
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
