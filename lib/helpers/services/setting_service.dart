import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:fasolingo/models/user_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/local_storage.dart';

class SettingService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstant.baseURl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

  /// Récupère le profil complet de l'utilisateur
  static Future<UserModel?> getUserProfile() async {
    try {
      final url = "${AppConstant.baseURl}/auth/profile"; 
      final token = await LocalStorage.getAuthToken();

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
      

      if (response.statusCode == 200 && response.data != null) {
        // LOG TEMPORAIRE — à supprimer après vérification
        print("🔍 [getUserProfile] response.data = ${response.data}");

        final dynamic data = response.data['data'];
        final dynamic userData = data is Map ? (data['user'] ?? data) : data;

        print("🔍 [getUserProfile] userData = $userData");

        if (userData != null) {
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } on DioException catch (e) {
      letMeHandleAllErrors(e);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// ************************* User Sign Out *************************///
  static Future<bool> userSignOut() async {
    try {
      final url = "${AppConstant.baseURl}/auth/logout";
      final token = await LocalStorage.getAuthToken();

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "accept": "*/*",
          },
        ),
      );
      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return true;
      
      letMeHandleAllErrors(e);
      return false;
    } catch (_) {
      return false;
    }
  }
}