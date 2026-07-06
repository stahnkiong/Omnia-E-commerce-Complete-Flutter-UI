import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pasar_now/components/skleton/skelton.dart';
import '../../../constants.dart';

class BannerS extends StatelessWidget {
  const BannerS({
    super.key,
    required this.image,
    this.press,
    required this.children,
    this.aspectRatio = 1.6,
    this.radius = 0,
  });

  final String image;
  final VoidCallback? press;
  final List<Widget> children;
  final double? aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = image.toLowerCase().startsWith('http');

    final Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: isNetworkImage
          ? CachedNetworkImage(
              fit: BoxFit.fitWidth,
              imageUrl: image,
              width: double.infinity,
              placeholder: (context, url) => AspectRatio(
                aspectRatio: aspectRatio ?? 1.6,
                child: const Skeleton(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : Image.asset(
              image,
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
    );

    final Widget mainContent = GestureDetector(
      onTap: press,
      child: Stack(
        children: [
          imageWidget,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              child: Container(color: const Color.fromARGB(28, 0, 0, 0)),
            ),
          ),
          ...children,
        ],
      ),
    );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: mainContent,
      );
    }

    return mainContent;
  }
}
