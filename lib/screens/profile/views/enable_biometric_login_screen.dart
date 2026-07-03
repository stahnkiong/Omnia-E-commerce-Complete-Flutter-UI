import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/services/biometric_auth_service.dart';

class EnableBiometricLoginScreen extends StatefulWidget {
  const EnableBiometricLoginScreen({super.key});

  @override
  State<EnableBiometricLoginScreen> createState() => _EnableBiometricLoginScreenState();
}

class _EnableBiometricLoginScreenState extends State<EnableBiometricLoginScreen> {
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  bool _isBiometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isBiometricEnabled = prefs.getBool('biometric_login_enabled') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      final isAvailable = await _biometricAuth.isBiometricAvailable();
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biometric authentication is not supported or set up on this device."),
              backgroundColor: errorColor,
            ),
          );
        }
        return;
      }

      // Prompt user to verify identity before enabling.
      final authenticated = await _biometricAuth.unlockSessionWithBiometrics();
      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_login_enabled', true);
        setState(() {
          _isBiometricEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biometric login enabled successfully."),
              backgroundColor: successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biometric verification failed. Could not enable biometric login."),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_login_enabled', false);
      setState(() {
        _isBiometricEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Biometric login disabled."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biometric Login"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Security Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Enable biometric login to securely and quickly access your account using your device's Face ID or fingerprint scanner.",
                    style: TextStyle(
                      color: blackColor60,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? darkGreyColor
                          : lightGreyColor,
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                    child: ListTile(
                      title: const Text(
                        "Enable Face ID / Fingerprint Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        activeTrackColor: primaryColor,
                        value: _isBiometricEnabled,
                        onChanged: _toggleBiometrics,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
