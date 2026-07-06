import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pasar_now/constants.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;
  final VoidCallback? onEmailSignInTap;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
    required this.onAppleTap,
    this.onEmailSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Cross-platform layout check using Theme platform to ensure ease of testing
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isIOS) ...[
          _buildAppleButton(context),
          const SizedBox(height: defaultPadding),
        ],
        _buildGoogleButton(context),
      ],
    );
  }

  // 2. Extracted Apple Button sub-widget using the official package widget
  Widget _buildAppleButton(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SignInWithAppleButton(
      key: const ValueKey('apple_sign_in_button'),
      onPressed: onAppleTap,
      style: isDarkTheme
          ? SignInWithAppleButtonStyle.white
          : SignInWithAppleButtonStyle.black,
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      height: 48,
    );
  }

  // 2. Extracted Google Button sub-widget
  Widget _buildGoogleButton(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton(
      key: const ValueKey('google_sign_in_button'),
      onPressed: onGoogleTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDarkTheme ? Colors.grey[900] : Colors.white,
        side: const BorderSide(color: blackColor20),
        padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/google.svg",
            height: 24,
            width: 24,
          ),
          const SizedBox(width: defaultPadding),
          Text(
            "Sign in with Google",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
