import 'package:fasolingo/helpers/my_widgets/my_spacing.dart';
import 'package:flutter/material.dart';

class RightSideBottomSheet extends StatefulWidget {
  final Widget screen;
  final double? width;

  const RightSideBottomSheet({super.key, required this.screen, this.width});
  @override
  _RightSideBottomSheetState createState() => _RightSideBottomSheetState();
}

class _RightSideBottomSheetState extends State<RightSideBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Starts from the right side
      end: Offset.zero, // Ends at the center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
            width: widget.width ?? MySpacing.fullWidth(context) * 0.25,
            child: widget.screen),
      ),
    );
  }
}
