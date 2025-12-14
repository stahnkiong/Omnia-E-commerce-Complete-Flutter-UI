import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/M/banner_m_style_1.dart';
import 'package:shop/components/Banner/M/banner_m_style_2.dart';
// import 'package:shop/components/Banner/M/banner_m_style_3.dart';
// import 'package:shop/components/Banner/M/banner_m_style_4.dart';
import 'package:shop/components/dot_indicators.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  // Offers List
  late List offers;

  @override
  void initState() {
    super.initState();
    offers = [
      BannerMStyle2(
        title: "Year End \n Promo",
        subtitle: "Free Shipping",
        image:
            "https://www.thewagyufactory.com.au/wp-content/uploads/2021/08/shutterstock_633879398-scaled.jpg",
        discountParcent: 20,
        press: () {
          Navigator.pushNamed(context, productCollectionScreenRoute,
              arguments: "pcol_01KBQKQXBG5460ANQZY9B0JQKX");
        },
      ),
      BannerMStyle1(
        text: "NZ Premium \n Free shipping",
        image:
            "https://beeflambnz.com/sites/default/files/styles/width_1440/public/2023-06/1200x383-origin-brand.jpg", //use custom image
        press: () {
          Navigator.pushNamed(context, productCollectionScreenRoute,
              arguments: "pcol_01KBW9TVVXRJDDWBK7S4876DBB");
        },
      ),

      // BannerMStyle3(
      //   title: "Grab \nyours now",
      //   discountParcent: 50,
      //   press: () {
      //     Navigator.pushNamed(context, onSaleScreenRoute);
      //   },
      // ),
      // BannerMStyle4(
      //   // image: , user your image
      //   title: "SUMMER \nSALE",
      //   subtitle: "SPECIAL OFFER",
      //   discountParcent: 80,
      //   press: () {
      //     Navigator.pushNamed(context, onSaleScreenRoute);
      //   },
      // ),
    ];
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_selectedIndex < offers.length - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }

      _pageController.animateToPage(
        _selectedIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.87,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: offers.length,
            onPageChanged: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            itemBuilder: (context, index) => offers[index],
          ),
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: List.generate(
                    offers.length,
                    (index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: defaultPadding / 4),
                        child: DotIndicator(
                          isActive: index == _selectedIndex,
                          activeColor: Colors.white70,
                          inActiveColor: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
