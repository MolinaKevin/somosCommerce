import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'screens/business_institution_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'helpers/translations_helper.dart';
import 'providers/language_provider.dart'; // Importar LanguageProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()), // Proveedor de AuthService
        ChangeNotifierProvider(create: (_) => LanguageProvider()), // Proveedor de LanguageProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenemos el proveedor de idiomas para cambiar el idioma dinámicamente
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: translate(context, 'appTitle') ?? 'Flutter Demo',
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
      // Aquí utilizamos el idioma seleccionado
      locale: Locale(languageProvider.currentLanguage),
      localeResolutionCallback: (locale, supportedLocales) {
        // Verificar si el idioma del dispositivo está soportado
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
  }
}
