import 'package:cached_network_image/cached_network_image.dart';
import 'package:fasolingo/helpers/constant/images.dart';
import 'package:flutter/material.dart';

class CatchNetworkImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BoxShape? shape;
  final Widget? imageWidget;
  const CatchNetworkImage(
      {super.key,
      required this.image,
      this.width,
      this.fit,
      this.imageWidget,
      this.shape,
      this.height});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      imageBuilder: (context, imageProvider) => AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              shape: shape ?? BoxShape.rectangle,
              image: DecorationImage(image: imageProvider, fit: fit)),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        height: height,
        width: width,
        child: const Center(
            child: CircularProgressIndicator(
          strokeWidth: 2.0,
          strokeAlign: -10,
        )),
      ),
      errorWidget: (context, url, error) => Image.asset(
        Images.appLogo,
        height: height,
        width: width,
      ),
    );
  }
}
