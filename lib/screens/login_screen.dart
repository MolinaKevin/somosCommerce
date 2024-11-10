import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'business_institution_screen.dart';
import '../helpers/translations_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translate(context, 'auth.login') ?? 'Login'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoTextField(
              controller: _emailController,
              placeholder: translate(context, 'auth.email') ?? 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: translate(context, 'auth.password') ?? 'Password',
              obscureText: true,
            ),
            SizedBox(height: 16),
            CupertinoButton.filled(
              child: authService.authStatus == AuthStatus.Authenticating
                  ? CupertinoActivityIndicator()
                  : Text(translate(context, 'auth.login') ?? 'Login'),
              onPressed: authService.authStatus == AuthStatus.Authenticating
                  ? null
                  : () async {
                final email = _emailController.text;
                final password = _passwordController.text;

                final success = await authService.login(email, password);

                if (success && mounted) {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (context) => BusinessInstitutionScreen(),
                    ),
                  );
                } else if (!success) {
                  if (mounted) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text(translate(context, 'errors.error') ?? 'Error'),
                        content: Text(translate(context, 'auth.loginFailed') ?? 'Failed to login.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text(translate(context, 'forms.accept') ?? 'Accept'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
