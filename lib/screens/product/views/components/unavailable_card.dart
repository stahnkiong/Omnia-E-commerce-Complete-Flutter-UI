import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class UnavailableCard extends StatelessWidget {
  const UnavailableCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
            border: Border.all(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withAlpha(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: SvgPicture.asset(
                    "assets/icons/Notification.svg",
                    colorFilter: const ColorFilter.mode(
                        Color.fromARGB(255, 188, 18, 5), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Text(
                    "Product Unavailable at the moment",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
