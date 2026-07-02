import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/route/screen_export.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class EntryPoint extends StatefulWidget {
  final int initialIndex;
  const EntryPoint({super.key, this.initialIndex = 0});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final List _pages = const [
    HomeScreen(),
    DiscoverScreen(),
    InventoryScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context).iconTheme.color!.withAlpha(
                    ((Theme.of(context).brightness == Brightness.dark
                                ? 0.3
                                : 1) *
                            255)
                        .toInt()),
            BlendMode.srcIn),
      );
    }

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
          "Omnia",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentIndex = 1;
              });
            },
            icon: SvgPicture.asset(
              "assets/icons/Search.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
          ValueListenableBuilder<Box>(
            valueListenable: Hive.box('notifications').listenable(),
            builder: (context, box, _) {
              final hasUnread = box.values.any((notification) {
                if (notification is Map) {
                  return notification['is_read'] == false;
                }
                return false;
              });

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, notificationsScreenRoute);
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/Notification.svg",
                      height: 24,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyLarge!.color!,
                          BlendMode.srcIn),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      // body: _pages[_currentIndex],
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF101015),
          type: BottomNavigationBarType.fixed,
          // selectedLabelStyle: TextStyle(color: primaryColor),
          selectedFontSize: 12,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.transparent,
          items: [
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Delivery.svg"),
              activeIcon:
                  svgIcon("assets/icons/Delivery.svg", color: primaryColor),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Category.svg"),
              activeIcon:
                  svgIcon("assets/icons/Category.svg", color: primaryColor),
              label: "Discover",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Product.svg"),
              activeIcon:
                  svgIcon("assets/icons/Product.svg", color: primaryColor),
              label: "Inventory",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Bag.svg"),
              activeIcon: svgIcon("assets/icons/Bag.svg", color: primaryColor),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Profile.svg"),
              activeIcon:
                  svgIcon("assets/icons/Profile.svg", color: primaryColor),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
