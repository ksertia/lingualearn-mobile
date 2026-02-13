import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // La couleur orange de ta ligne 5
    const Color orangeAccent = Color(0xFFFF8C00);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: AppBar(
          // Toute la barre devient orange ici
          backgroundColor: orangeAccent,
          elevation: 0,
          leadingWidth: kToolbarHeight,
          // L'icône de retour devient noire ou blanche pour être visible sur l'orange
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black, // Texte en noir comme sur ton exemple
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}