import 'dart:ui';

import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:flutter/material.dart';

class BlurredBackdropImage extends StatelessWidget {
  const BlurredBackdropImage({
    Key? key,
    required this.imageId,
    this.height = 200,
  }) : super(key: key);

  final String imageId;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            "${AppConstant.baseURl}${AppConstant.resources}/$imageId/${AppConstant.renditions}/${AppConstant.imgPreview}",
          ),
          fit: BoxFit.fill,
        ),
      ),
      height: height,
      width: MySpacing.fullWidth(context),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.0),
            ),
          )),
    );
  }
}
