import 'package:get/get.dart';

class SessionController extends GetxController {
  // Cette variable dit si l'utilisateur est un visiteur qui découvre
  bool vientDeLaDecouverte = false;
  
  // Stocke la langue choisie pendant la découverte
  String langueChoisie = "";

  // Fonction pour réinitialiser après le login si besoin
  void reset() {
    vientDeLaDecouverte = false;
    langueChoisie = "";
  }
}