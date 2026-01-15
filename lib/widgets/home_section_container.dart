import 'package:flutter/material.dart';

class HomeSectionContainer extends StatelessWidget {
  final String title;
  final String? description;
  final bool? showViewAll;
  final String? viewAllText;
  final Widget child;
  final VoidCallback? onViewAllPressed;
  const HomeSectionContainer(
      {super.key,
      required this.title,
      this.description,
      this.onViewAllPressed,
      this.showViewAll = true,
      this.viewAllText = "Voir plus",
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black),
              ),
              showViewAll!
                  ? TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: onViewAllPressed,
                      child: Text(
                        viewAllText!,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF00374A),
                            decoration: TextDecoration.underline),
                      ))
                  : const SizedBox.shrink()
            ],
          ),
        ),
        if (description != null)
          Text(description!, style: TextStyle(fontSize: 12)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
