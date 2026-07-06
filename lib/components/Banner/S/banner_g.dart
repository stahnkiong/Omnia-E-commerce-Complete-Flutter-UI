import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';
import 'banner_s.dart';

class BannerG extends StatelessWidget {
  const BannerG({
    super.key,
    this.image =
        "https://images.unsplash.com/photo-1633073547946-92ff810b1cca?q=80&w=1170&auto=format&fit=crop",
    required this.press,
    this.title,
    this.subtitle,
    this.aspectRatio,
    this.isActive = true,
  });

  final String? image;
  final VoidCallback press;
  final String? title;
  final String? subtitle;
  final double? aspectRatio;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final bool hasOverlay = (title != null && title!.isNotEmpty) ||
        (subtitle != null && subtitle!.isNotEmpty);

    return BannerS(
      image: image!,
      press: isActive ? press : null,
      aspectRatio: aspectRatio,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasOverlay)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null && title!.isNotEmpty)
                                Text(
                                  title!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              if (title != null &&
                                  title!.isNotEmpty &&
                                  subtitle != null &&
                                  subtitle!.isNotEmpty)
                                const SizedBox(height: 4),
                              if (subtitle != null && subtitle!.isNotEmpty)
                                Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(height: defaultPadding / 4),
                    ],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: defaultPadding),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: press,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/Arrow - Right.svg",
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
