import 'package:fasolingo/helpers/services/langue/discover_service.dart';
import 'package:fasolingo/models/langue/decouverte_model.dart';
import 'package:flutter/material.dart';

class DiscoverController extends ChangeNotifier {
  final DiscoverService _service = DiscoverService();

  List<String> languages = [];
  LanguageData? languageContent;
  String? selectedLanguage;

  bool isLoading = false;
  String? error;

  // Initialisation : Charger les langues
  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      languages = await _service.getAllLanguages();
    } catch (e) {
      error = "Impossible de charger les langues";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Sélection d'une langue
  Future<void> selectLanguage(String language) async {
    // Si c'est déjà la langue sélectionnée, on ne fait rien
    if (selectedLanguage == language && languageContent != null) return;

    selectedLanguage = language;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      languageContent = await _service.getContentByLanguage(language);

      // Tri automatique par le champ 'order'
      languageContent?.lessons.sort((a, b) => a.order.compareTo(b.order));
      languageContent?.exercises.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      error = "Erreur de chargement pour $language";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
