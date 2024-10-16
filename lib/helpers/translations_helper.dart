import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

String? translate(BuildContext context, String key) {
  return AppLocalizations.of(context)?.translate(key);
}
