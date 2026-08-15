import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:get/get.dart';
import '../../../models/etapes/steps_model.dart';

class StepService {
  Dio get _dio => Get.find<SessionController>().dio;

  /// Lance une [DioException] 
  /// [Exception] descriptive si la réponse est mal formée — le contrôleur
  Future<StepData> getStepContent(String stepId, {String? userId}) async {
    final Map<String, dynamic> queryParams = {};
    if (userId != null) {
      queryParams['userId'] = userId;
    }

    final response = await _dio.get(
      '/steps/$stepId/content',
      queryParameters: queryParams,
    );

    if (response.data['success'] != true) {
      throw Exception(
          'Réponse serveur inattendue (success=false) : ${response.data}');
    }

    final raw = response.data['data'];
    if (raw == null) {
      throw Exception('Le serveur a renvoyé data=null pour cette étape.');
    }

    final data = Map<String, dynamic>.from(raw as Map);
    if (data['content'] == null) {
      throw Exception(
          "Cette étape n'a pas encore de contenu (content=null) — payload: $data");
    }

    return StepData.fromJson(data);
  }

  /// Leçon d'une étape avec ses blocs (texte/vidéo/image/audio) et sa progression.
  Future<LessonContent> getStepLessons(String stepId, {String? userId}) async {
    final Map<String, dynamic> queryParams = {};
    if (userId != null) {
      queryParams['userId'] = userId;
    }

    final response = await _dio.get(
      '/courses/step/$stepId/lessons',
      queryParameters: queryParams,
    );

    if (response.data['success'] != true) {
      throw Exception(
          'Réponse serveur inattendue (success=false) : ${response.data}');
    }

    final raw = response.data['data'];
    if (raw == null) {
      throw Exception('Le serveur a renvoyé data=null pour cette étape.');
    }

    return LessonContent.fromJson(Map<String, dynamic>.from(raw as Map));
  }
}
