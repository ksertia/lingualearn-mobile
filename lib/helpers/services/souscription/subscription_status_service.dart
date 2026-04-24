import 'package:dio/dio.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/models/souscription/subscription_status_model.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class SubscriptionStatusService {
  static final _session = Get.find<SessionController>();
  static bool _loggerAdded = false;

  static void _ensureLogger() {
    if (_loggerAdded) return;
    _session.dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 120,
    ));
    _loggerAdded = true;
  }

  static Future<SubscriptionStatusModel?> fetchMyStatus() async {
    try {
      _ensureLogger();
      final response =
          await _session.dio.get('/subscriptions/my-status');
      if (response.statusCode == 200 && response.data is Map) {
        return SubscriptionStatusModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      return null;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erreur réseau';
      print('SubscriptionStatusService error: $msg');
      return null;
    } catch (e) {
      print('SubscriptionStatusService unexpected: $e');
      return null;
    }
  }
}
