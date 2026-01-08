import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:provider/provider.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/food_20and_20drink.webp",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: defaultPadding),
                  Text(
                    "PasarNow",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Members enjoy lower Cash on Delivery rates\nLog in now!",
                  ),
                  const SizedBox(height: defaultPadding),
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, entryPointScreenRoute);
                    },
                    child: const Text("Demo"),
                  ),
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
                  const SizedBox(height: defaultPadding * 2),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
