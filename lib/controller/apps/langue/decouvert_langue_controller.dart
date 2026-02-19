import 'package:fasolingo/helpers/services/langue/decouvert_langue_service.dart';
import 'package:fasolingo/models/langue/decouvert_langue.dart';
import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();

  // --- ÉTAT DE L'INTERFACE ---
  List<LanguageDiscover> languages = [];
  bool isLoading = false;
  String? errorMessage;
  
  // ID de la langue sélectionnée par l'utilisateur
  String? selectedLanguageId;

  // --- GETTER ---
  // Récupère l'objet complet de la langue sélectionnée
  LanguageDiscover? get selectedLanguage => 
      selectedLanguageId == null 
      ? null 
      : languages.firstWhere((lang) => lang.id == selectedLanguageId);

  // --- MÉTHODES ---

  /// Charge les langues depuis le service
  Future<void> fetchLanguages() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Prévient la vue qu'on charge

    try {
      final fetchedLanguages = await _languageService.getDiscoverLanguages();
      
      // Tri par index (champ présent dans ton modèle)
      fetchedLanguages.sort((a, b) => a.index.compareTo(b.index));
      
      languages = fetchedLanguages;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners(); // Prévient la vue que c'est fini (succès ou erreur)
    }
  }

  /// Sélectionne une langue
  void selectLanguage(String id) {
    if (selectedLanguageId == id) {
      selectedLanguageId = null; // Désélectionne si on reclique
    } else {
      selectedLanguageId = id;
    }
    notifyListeners();
  }
}