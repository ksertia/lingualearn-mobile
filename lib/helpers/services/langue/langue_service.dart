import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:get/get.dart'; 
import 'package:fasolingo/controller/apps/session_controller.dart';

class LanguageLevelService {
  late final Dio _dio;

  LanguageLevelService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstant.baseURl, 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          final session = Get.find<SessionController>();
          
          // Essayer d'obtenir le token depuis la session
          String? tokenToUse = session.token.value.isNotEmpty 
              ? session.token.value 
              : null;
          
          // Si pas de token en session, essayer le stockage local
          tokenToUse ??= LocalStorage.getAuthToken();
          
          if (tokenToUse != null && tokenToUse.isNotEmpty && tokenToUse != "null") {
            options.headers['Authorization'] = 'Bearer $tokenToUse';
            print("🔑 Token injecté : ${tokenToUse.substring(0, 10)}...");
          } else {
            print("⚠️ Attention : Aucun token trouvé !");
          }
        } catch (e) {
          print("⚠️ Erreur lors de la récupération du token : $e");
        }
        return handler.next(options);
      },
    ));
  }

  // --- RÉCUPÉRATION DES LANGUES ---
  Future<List<LanguageModel>> fetchLanguages({required String userId}) async {
    try {
      final response = await _dio.get('/users/$userId/languages'); 
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'];
        if (responseData == null || responseData is! List) return [];
        return responseData
            .map((item) => LanguageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print("❌ Erreur Fetch Langues : ${e.response?.data ?? e.message}");
      return [];
    }
  }

  // --- SAUVEGARDE DE LA LANGUE ---
  Future<bool> selectLanguageForUser({required String userId, required String languageId}) async {
    try {
      final String path = '/users/$userId/languages/$languageId/select';
      print("🚀 Requête Langue : $path");
      
      final response = await _dio.post(path);
      
      print("✅ Réponse Langue (${response.statusCode}) : ${response.data}");
      return (response.statusCode == 201 || response.statusCode == 200);
    } on DioException catch (e) {
      print("❌ Erreur Sélection Langue : ${e.response?.data}");
      return false;
    }
  }

  // --- RÉCUPÉRATION DES NIVEAUX ---
  Future<List<dynamic>> fetchLevels({required String userId, String? languageId}) async {
    try {
      // Endpoint: /users/{userId}/level with optional languageId query
      final response = await _dio.get(
        '/users/$userId/levels'
      );
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("❌ Erreur Fetch Niveaux : $e");
      return [];
    }
  }

  // --- SAUVEGARDE DU NIVEAU ---
  Future<bool> selectLevelForUser({
    required String userId,
    required String levelId,
  }) async {
    try {
      final String path = '/users/$userId/levels/$levelId/select'; 
      
      print("🚀 Requête Niveau : $path");
      final response = await _dio.post(path);

      print("✅ Réponse Niveau (${response.statusCode}) : ${response.data}");
      return (response.statusCode == 201 || response.statusCode == 200);
    } on DioException catch (e) {
      print("❌ Erreur Dio Level Select (${e.response?.statusCode}) : ${e.response?.data}");
      return false;
    }
  }

  // --- RÉCUPÉRATION DES MODULES ---
  Future<List<dynamic>> fetchModules({required String userId}) async {
    try {
      final response = await _dio.get('/users/$userId/modules'); 
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("❌ Erreur Fetch Modules : $e");
      return [];
    }
  }

  // --- RÉCUPÉRATION DE LA PROGRESSION (inclut les niveaux) ---
  Future<Map<String, dynamic>?> fetchProgression({required String userId, required String languageId}) async {
    try {
      final response = await _dio.get('/progression/user/$userId/language/$languageId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("❌ Erreur Fetch Progression : $e");
      return null;
    }
  }
}
