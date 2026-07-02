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
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:pasar_now/config.dart';
import 'package:pasar_now/providers/wishlist_provider.dart';
import 'package:pasar_now/providers/inventory_provider.dart';
import 'package:pasar_now/services/cart_service.dart';
import 'package:pasar_now/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Stripe.publishableKey = AppConfig.stripePublishableKey;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  /// Listens for incoming `omniafoods://auth-callback?code=...` URIs and
  /// navigates to [GoogleAuthCallbackScreen] with the extracted code.
  void _initDeepLinkListener() {
    _appLinks.uriLinkStream.listen((Uri uri) {
      if (uri.scheme == 'omniafoods' && uri.host == 'auth-callback') {
        final String? code = uri.queryParameters['code'];
        if (code != null && code.isNotEmpty) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            googleAuthCallbackScreenRoute,
            (route) => false,
            arguments: code,
          );
        }
      }
    });
  }

  Widget _buildMaterialApp(BuildContext context, String initialRoute) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Omnia',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return FutureBuilder(
      future: Future.wait([
        authProvider.initialize(),
        CartService().validateCart(),
      ]),
      builder: (context, snapshot) {
        final authStatus = Provider.of<AuthProvider>(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

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
