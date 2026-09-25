import 'package:tibi/helpers/services/langue/discover_service.dart';
import 'package:tibi/models/langue/decouverte_model.dart';
import 'package:flutter/material.dart';

class DiscoverController extends ChangeNotifier {
  final DiscoverService _service = DiscoverService();

  List<DiscoverLanguage> languages = [];
  DemoLanguageData? demoContent;
  DiscoverLanguage? selectedLanguage;

  bool isLoading = false;
  String? error;

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

  Future<void> selectLanguage(DiscoverLanguage language) async {
    if (selectedLanguage?.code == language.code && demoContent != null) {
      return;
    }
    selectedLanguage = language;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      demoContent = await _service.getDemoContentByLanguage(language.code);
      demoContent?.contents.sort((a, b) => a.index.compareTo(b.index));
    } catch (e) {
      error = "Erreur de chargement pour ${language.name}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
