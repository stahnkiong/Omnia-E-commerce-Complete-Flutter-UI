import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:shop/services/cart_service.dart';

void main() {
  Stripe.publishableKey =
      'pk_test_51SnE0nHVeaSTBf7hNyFNTAy1pPL12sXYAFbnBRp8VYdHPlzdIQqxMflRyefGQWCzVKp2BSPp6fXt87yGVSHtEcrt00tvxjkD03';
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Widget _buildMaterialApp(BuildContext context, String initialRoute) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PasarNow',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialRoute,
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return FutureBuilder(
      future: Future.wait([
        authProvider.initialize(),
        CartService().validateCart(),
      ]), // Run the check here
      builder: (context, snapshot) {
        final authStatus = Provider.of<AuthProvider>(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a splash screen while checking the token
          return const Center(child: CircularProgressIndicator());
        }

        // Decide the entry route based on the token status
        if (authStatus.isAuthenticated) {
          return _buildMaterialApp(context, entryPointScreenRoute);
        } else {
          return _buildMaterialApp(context, onbordingScreenRoute);
        }
      },
    );
  }
}
