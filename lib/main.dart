import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:pasar_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:pasar_now/providers/product_provider.dart';
import 'package:pasar_now/route/router.dart' as router;
import 'package:pasar_now/theme/app_theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:pasar_now/providers/wishlist_provider.dart';
import 'package:pasar_now/services/cart_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Stripe.publishableKey =
      'pk_test_51SnE0nHVeaSTBf7hNyFNTAy1pPL12sXYAFbnBRp8VYdHPlzdIQqxMflRyefGQWCzVKp2BSPp6fXt87yGVSHtEcrt00tvxjkD03';
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
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
      title: 'Pasar Now',
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
          return _buildMaterialApp(context,
              kIsWeb ? webEntryPointScreenRoute : entryPointScreenRoute);
        } else {
          return _buildMaterialApp(context,
              kIsWeb ? webEntryPointScreenRoute : onbordingScreenRoute);
        }
      },
    );
  }
}
