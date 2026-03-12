import 'package:flutter/material.dart';
import 'package:pasar_now/components/Banner/S/banner_s_style_1.dart';
import 'package:pasar_now/components/Banner/S/banner_s_style_5.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/route/screen_export.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/featured_products.dart';
import 'components/categories.dart';
import 'components/popular_products.dart';
import 'home_screen_images.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  "Categories",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Categories()),
            const SliverToBoxAdapter(child: PopularProducts()),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(child: FlashSale()),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // While loading use 👇
                  // const BannerMSkelton(),‚
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    image: HomeScreenImages.banner3,
                    discountParcent: 30,
                    press: () {
                      Navigator.pushNamed(context, productCollectionScreenRoute,
                          arguments: "pcol_01KBW9VHQ59C8BF6HHJYJYYWJG");
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
            const SliverToBoxAdapter(child: FeaturedProducts()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),

                  const SizedBox(height: defaultPadding / 4),
                  // While loading use 👇
                  // const BannerSSkelton(),
                  BannerSStyle5(
                    title: "TGI \nFriday",
                    subtitle: "50% Off",
                    image: HomeScreenImages.banner4,
                    bottomText: "Collection".toUpperCase(),
                    press: () {
                      Navigator.pushNamed(context, productCollectionScreenRoute,
                          arguments: "pcol_01KBW9VHQ59C8BF6HHJYJYYWJG");
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
          ],
        ),
      ),
    );
  }
}
