import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'screens/business_institution_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
