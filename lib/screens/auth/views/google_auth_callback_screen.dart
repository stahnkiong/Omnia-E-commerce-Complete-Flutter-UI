import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/providers/auth_provider.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:provider/provider.dart';

/// Shown briefly while the app exchanges the OAuth code for a Medusa JWT.
///
/// Navigation to this screen is triggered by [MyApp]'s deep-link listener
/// in main.dart. It receives the authorization [code] extracted from the
/// incoming `omniafoods://auth-callback?code=...` URI.
class GoogleAuthCallbackScreen extends StatefulWidget {
  final String code;

  const GoogleAuthCallbackScreen({super.key, required this.code});

  @override
  State<GoogleAuthCallbackScreen> createState() =>
      _GoogleAuthCallbackScreenState();
}

class _GoogleAuthCallbackScreenState extends State<GoogleAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    // Run the handshake on the next frame so the widget tree is fully mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleCallback());
  }

  Future<void> _handleCallback() async {
    final auth = context.read<AuthProvider>();
    final bool success = await auth.handleGoogleCallback(widget.code);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        (route) => false,
      );
    } else {
      // Handshake failed — return to login with an error message.
      Navigator.pushNamedAndRemoveUntil(
        context,
        logInScreenRoute,
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in failed. Please try again.'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              'Completing sign-in…',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: blackColor60,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
