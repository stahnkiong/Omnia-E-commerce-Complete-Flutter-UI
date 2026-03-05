import 'package:flutter/material.dart';
import 'package:pasar_now/route/screen_export.dart';

class WebEntryPoint extends StatelessWidget {
  const WebEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WebHomeScreen(),
    );
  }
}
