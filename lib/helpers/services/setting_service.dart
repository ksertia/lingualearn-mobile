import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:fasolingo/models/user_model.dart';
import '../storage/local_storage.dart';

class SettingService {
  /// Récupère le profil complet de l'utilisateur
  static Future<UserModel?> getUserProfile() async {
    try {
      final url = "${AppConstant.baseURl}/auth/profile"; 
      final token = await LocalStorage.getAuthToken();

      print("[Profile API] URL: $url");

      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("[Profile API] StatusCode: ${response.statusCode}");
      
      // On vérifie le code 200 ET la structure de tes données
      if (response.statusCode == 200 && response.data != null) {
        // Selon ton Swagger, les données sont souvent dans data -> user
        final dynamic userData = response.data['data']['user']; 
        
        if (userData != null) {
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } on DioException catch (e) {
      print("[Profile API] DioException: ${e.message}");
      letMeHandleAllErrors(e); // Ton utilitaire de gestion d'erreurs
      return null;
    } catch (e) {
      print("[Profile API] Erreur inconnue: $e");
      return null;
    }
  }

  /// ************************* User Sign Out *************************///
  static Future<bool> userSignOut() async {
    try {
      final url = "${AppConstant.baseURl}/auth/logout";
      final token = await LocalStorage.getAuthToken();
      
      print("[Logout API] URL: $url");
      
      final response = await Dio().post(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "accept": "*/*", // Recommandé par Swagger
          },
        ),
      );
      
      print("[Logout API] StatusCode: ${response.statusCode}");
      print("[Logout API] Response: ${response.data}");

      // On valide si le status est 200 OU si le corps dit success: true
      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      
      return false;
    } on DioException catch (e) {
      print("[Logout API] DioException: ${e.message}");
      // Si le token est déjà expiré, on considère que c'est un succès local 
      // pour ne pas bloquer l'utilisateur sur l'écran
      if (e.response?.statusCode == 401) return true;
      
      letMeHandleAllErrors(e);
      return false;
    } catch (e) {
      print("[Logout API] Erreur: $e");
      return false;
    }
  }
}