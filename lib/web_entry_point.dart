import 'package:flutter/material.dart';
import 'package:pasar_now/route/screen_export.dart';

class WebEntryPoint extends StatelessWidget {
  const WebEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // pinned: true,
        // floating: true,
        // snap: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Text(
          "Pasar Now",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: const WebHomeScreen(),
    );
  }
}
