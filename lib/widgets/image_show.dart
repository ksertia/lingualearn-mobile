import 'package:cached_network_image/cached_network_image.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:fasolingo/views/ui/catch_network_image.dart';
import 'package:flutter/material.dart';

class GetNetworkImage extends StatefulWidget {
  final String? imageID;
  final String? status;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;
  final bool isFlagIcon;

  const GetNetworkImage(
      {super.key,
      required this.imageID,
      this.width,
      this.status,
      this.height,
      this.fit,
      this.isFlagIcon = false,
      this.borderRadius});

  @override
  State<GetNetworkImage> createState() => _GetNetworkImageState();
}

class _GetNetworkImageState extends State<GetNetworkImage> {
  @override
  void initState() {
    super.initState();
    if (widget.isFlagIcon == false) {
      CachedNetworkImage.evictFromCache(
          "${AppConstant.baseURl}${AppConstant.resources}/${widget.imageID}/${AppConstant.renditions}/${AppConstant.imgPreview}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.status == "CLOSED"
        ? ColorFiltered(
            colorFilter: ColorFilter.matrix(
              <double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ],
            ),
            child: CatchNetworkImage(
              image:
                  "${AppConstant.baseURl}${AppConstant.resources}/${widget.imageID}/${AppConstant.renditions}/${AppConstant.imgPreview}",
              width: widget.width ?? MySpacing.fullWidth(context),
              height: widget.height ?? 180,
              fit: BoxFit.fill,
            ))
        : CatchNetworkImage(
            image: widget.imageID != null
                ? widget.isFlagIcon
                    ? "${AppConstant.baseFlagURl}/${widget.imageID}.svg"
                    : "${AppConstant.baseURl}${AppConstant.resources}/${widget.imageID}/${AppConstant.renditions}/${AppConstant.imgPreview}"
                : "",
            width: widget.width ?? MySpacing.fullWidth(context),
            height: widget.height ?? 180,
            fit: widget.fit,
          );
  }
}
