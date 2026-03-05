import 'package:flutter/material.dart';
import 'package:pasar_now/components/Banner/S/banner_s_style_1.dart';
import 'package:pasar_now/components/Banner/M/banner_m_style_1.dart';
import 'package:pasar_now/components/Banner/M/banner_m_style_2.dart';
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
                  // While loading use 👇
                  // const BannerMSkelton(),‚
                  BannerMStyle2(
                    title: "Year End \n Promo",
                    subtitle: "Free Shipping",
                    image: HomeScreenImages.bannerMStyle2Image,
                    discountParcent: 20,
                    press: () {},
                  ),
                  BannerMStyle1(
                    text: "NZ Premium \n Free shipping",
                    image:
                        HomeScreenImages.bannerMStyle1Image, //use custom image
                    press: () {},
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // While loading use 👇
                  // const BannerMSkelton(),‚
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    image: HomeScreenImages.bannerSStyle1Image,
                    discountParcent: 30,
                    press: () {},
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // While loading use 👇
                  // const BannerSSkelton(),
                  BannerSStyle5(
                    title: "TGI \nFriday",
                    subtitle: "50% Off",
                    image: HomeScreenImages.bannerSStyle5Image,
                    bottomText: "Collection".toUpperCase(),
                    press: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
