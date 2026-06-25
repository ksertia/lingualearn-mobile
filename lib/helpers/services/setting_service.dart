import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/models/user_model.dart';
import 'package:get/get.dart';

class SettingService {
  static Dio get _dio => Get.find<SessionController>().dio;

  /// Récupère le profil complet de l'utilisateur
  static Future<UserModel?> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        final dynamic userData = data is Map ? (data['user'] ?? data) : data;
        if (userData != null) return UserModel.fromJson(userData);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Déconnexion
  static Future<bool> userSignOut() async {
    try {
      final response = await _dio.post('/auth/logout');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return true;
      return false;
    } catch (_) {
      return false;
    }
  }
}