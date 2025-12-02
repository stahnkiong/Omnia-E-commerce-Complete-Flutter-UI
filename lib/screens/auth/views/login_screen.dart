import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api_service.dart';
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
              "assets/images/login_dark.png",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your data that you intered during your registration.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    onEmailSaved: (v) => _email = v,
                    onPasswordSaved: (v) => _password = v,
                  ),

                  Align(
                    child: TextButton(
                      child: const Text("Forgot password"),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, passwordRecoveryScreenRoute);
                      },
                    ),
                  ),
                  SizedBox(
                    height:
                        size.height > 700 ? size.height * 0.1 : defaultPadding,
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (_formKey.currentState!.validate()) {
                  //       Navigator.pushNamedAndRemoveUntil(
                  //           context,
                  //           entryPointScreenRoute,
                  //           ModalRoute.withName(logInScreenRoute));
                  //     }
                  //   },
                  //   child: const Text("Log in"),
                  // ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          try {
                            // Access AuthProvider

                            final auth = Provider.of<AuthProvider>(context,
                                listen: false);

                            print("Saved email: $_email");
                            print("Saved password: $_password");
                            await auth.login(_email, _password);

                            // Logged in successfully
                            Navigator.pushNamedAndRemoveUntil(context,
                                entryPointScreenRoute, (route) => false);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Login failed. Check email/password or connection.')),
                            );
                          }
                        }
                      },
                      child: const Text("Log in")),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final response = await ApiService()
                            .client
                            .get("/auth/customer/emailpass");
                        print(response.data);
                      } catch (e) {
                        print("API test failed: $e");
                      }
                    },
                    child: const Text("Test API"),
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
