import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/models/langue/decouverte_model.dart';
import 'package:get/get.dart';

class DiscoverService {
  Dio get _dio => Get.find<SessionController>().dio;

  // Récupère les noms des langues
  Future<List<String>> getAllLanguages() async {
    try {
      final response = await _dio.get('/discover/languages');
      final List<dynamic> rawData = response.data['data'] ?? [];
      return rawData.map((lang) => lang.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Récupère les leçons et exercices
  Future<LanguageData> getContentByLanguage(String language) async {
    try {
      final response = await _dio.get('/discover/languages/$language');
      return LanguageData.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}