import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/providers/auth_provider.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // String _email = "";
  // String _password = "";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Image.asset(
            "assets/images/food_20and_20drink.webp",
            height: size.height * 0.45,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PasarNow",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Members enjoy lower Cash on Delivery rates\nLog in now!",
                  ),
                  const SizedBox(height: defaultPadding),
                  /*
                  LogInForm(
                    formKey: _formKey,
                    onEmailSaved: (v) => _email = v,
                    onPasswordSaved: (v) => _password = v,
                  ),
                  // Align(
                  //   child: TextButton(
                  //     child: const Text("Forgot password"),
                  //     onPressed: () {
                  //       Navigator.pushNamed(
                  //           context, passwordRecoveryScreenRoute);
                  //     },
                  //   ),
                  // ),
                  SizedBox(
                    height:
                        size.height > 700 ? size.height * 0.04 : defaultPadding,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          final auth =
                              Provider.of<AuthProvider>(context, listen: false);

                          final success = await auth.login(_email, _password);
                          if (!context.mounted) return;
                          if (success) {
                            // Logged in successfully
                            Navigator.pushNamedAndRemoveUntil(context,
                                entryPointScreenRoute, (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Login failed. Check email/password.')),
                            );
                          }
                        }
                      },
                      child: const Text("Log in")),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Text(
                          "OR",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: greyColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  */
                  OutlinedButton(
                    onPressed: () async {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      try {
                        final redirectUrl = await auth.loginWithGoogle();
                        if (!context.mounted) return;
                        if (redirectUrl != null) {
                          final Uri url = Uri.parse(redirectUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw Exception('Could not launch $redirectUrl');
                          }
                        } else {
                          if (!context.mounted) return;
                          if (auth.isAuthenticated) {
                            Navigator.pushNamedAndRemoveUntil(context,
                                entryPointScreenRoute, (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Google Authentication failed.')),
                            );
                          }
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to initiate login: $e')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blackColor20),
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding * 0.75),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
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
                          "Login with Google",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  /*
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                  */
                  const SizedBox(height: defaultPadding * 2),
                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
