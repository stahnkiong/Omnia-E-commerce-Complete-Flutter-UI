import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = src.toLowerCase().startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: isNetworkImage
          ? CachedNetworkImage(
              fit: fit,
              imageUrl: src,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: fit,
                  ),
                ),
              ),
              placeholder: (context, url) => const Skeleton(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : Image.asset(
              src,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
    );
  }
}
