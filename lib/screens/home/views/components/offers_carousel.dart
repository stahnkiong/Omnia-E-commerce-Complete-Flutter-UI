import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/M/banner_m_style_1.dart';
import 'package:shop/components/Banner/M/banner_m_style_2.dart';
import 'package:shop/components/Banner/M/banner_m_style_3.dart';
import 'package:shop/components/Banner/M/banner_m_style_4.dart';
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
      BannerMStyle1(
        text: "New items with \nFree shipping",
        // image: "https://i.imgur.com/J1Qjut7.png", use custom image
        press: () {
          Navigator.pushNamed(context, productCollectionScreenRoute,
              arguments: "pcol_01KBW9TVVXRJDDWBK7S4876DBB");
        },
      ),
      BannerMStyle2(
        title: "Black \nfriday",
        subtitle: "Collection",
        discountParcent: 50,
        press: () {
          Navigator.pushNamed(context, productCollectionScreenRoute,
              arguments: "pcol_01KBQKQXBG5460ANQZY9B0JQKX");
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
