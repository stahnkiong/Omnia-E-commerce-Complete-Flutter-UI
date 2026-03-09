import 'package:flutter/material.dart';
import 'package:pasar_now/components/Banner/S/banner_s_style_1.dart';
import 'package:pasar_now/components/Banner/S/banner_s_style_5.dart';

import 'home_screen_images.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Image.asset(
                    HomeScreenImages.banner1,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    HomeScreenImages.banner2,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    // While loading use 👇
                    // const BannerSSkelton(),
                    BannerSStyle5(
                      title: "TGI \nFriday",
                      subtitle: "50% Off",
                      image: HomeScreenImages.banner3,
                      bottomText: "Collection".toUpperCase(),
                      press: () {},
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    // While loading use 👇
                    // const BannerMSkelton(),‚
                    BannerSStyle1(
                      title: "New \narrival",
                      subtitle: "SPECIAL OFFER",
                      image: HomeScreenImages.banner4,
                      discountParcent: 30,
                      press: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
