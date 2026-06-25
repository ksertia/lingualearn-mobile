import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:get/get.dart';
import '../../../models/etapes/steps_model.dart';

class StepService {
  Dio get _dio => Get.find<SessionController>().dio;

  Future<StepData?> getStepContent(String stepId, {String? userId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (userId != null) {
        queryParams['userId'] = userId;
      }

      final response = await _dio.get(
        '/steps/$stepId/content',
        queryParameters: queryParams,
      );
      if (response.data['success'] == true) {
        final raw = response.data['data'];
        if (raw == null) return null;
        final data = Map<String, dynamic>.from(raw as Map);
        if (data['content'] == null) return null;
        return StepData.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
