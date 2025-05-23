import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

String? translate(BuildContext context, String key) {
  final localizations = AppLocalizations.of(context);
  if (localizations == null) {
    print('AppLocalizations.of(context) es null');
    return null;
  } else {
    return localizations.translate(key);
  }
}
