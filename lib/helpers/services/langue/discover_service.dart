import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/models/langue/decouverte_model.dart';
import 'package:get/get.dart';

class DiscoverService {
  Dio get _dio => Get.find<SessionController>().dio;

  // Récupère les langues disponibles à la découverte
  Future<List<DiscoverLanguage>> getAllLanguages() async {
    try {
      final response = await _dio.get('/discover/languages');
      final List<dynamic> rawData = response.data['data'] ?? [];
      return rawData
          .map((lang) => DiscoverLanguage.fromJson(Map<String, dynamic>.from(lang)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Récupère les leçons et exercices d'une langue (identifiée par son code, ex: "DYU")
  Future<LanguageData> getContentByLanguage(String languageCode) async {
    try {
      final response = await _dio.get('/discover/languages/$languageCode');
      return LanguageData.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Récupère le sous-thème de démonstration pour une langue : cours + exercice
  Future<DemoLanguageData> getDemoContentByLanguage(String languageCode) async {
    try {
      final response = await _dio.get('/discover/languages/$languageCode/demo');
      return DemoLanguageData.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Vérifie la réponse à l'exercice de démonstration (sans compte) : isCorrect + explication
  Future<DemoTryResult> tryDemoExercise(String contentId, String answer) async {
    try {
      final response = await _dio.post(
        '/discover/demo/$contentId/try',
        data: {'answer': answer},
      );
      return DemoTryResult.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Récupère la structure pédagogique complète d'une langue (niveaux > modules > thèmes)
  Future<LanguagePreview> getLanguagePreview(String languageCode) async {
    try {
      final response = await _dio.get('/discover/languages/$languageCode/preview');
      return LanguagePreview.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}