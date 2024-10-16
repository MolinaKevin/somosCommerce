import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'screens/business_institution_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'helpers/translations_helper.dart';
import 'providers/language_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()), // Cargar el idioma al iniciar
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          key: ValueKey(languageProvider.currentLanguage),  // Clave única para forzar el rebuild
          title: translate(context, 'appTitle') ?? 'Flutter Demo',
          locale: Locale(languageProvider.currentLanguage), // Usar el idioma actual
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // Inglés
            Locale('es', ''), // Español
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          home: FutureBuilder(
            future: Provider.of<AuthService>(context, listen: false).tryAutoLogin(),
            builder: (ctx, authResultSnapshot) {
              if (authResultSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return Provider.of<AuthService>(context, listen: false).isAuth
                    ? BusinessInstitutionScreen()
                    : LoginScreen();
              }
            },
          ),
        );
      },
    );
  }
}
