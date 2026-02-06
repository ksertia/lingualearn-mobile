import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
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
        final session = Get.find<SessionController>();
        
        if (session.token.value.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${session.token.value}';
          print("🔑 Token injecté : ${session.token.value.substring(0, 10)}...");
        } else {
          print("⚠️ Attention : Aucun token trouvé dans la session !");
        }
        return handler.next(options);
      },
    ));
  }

  // --- RÉCUPÉRATION DES LANGUES ---
  Future<List<LanguageModel>> fetchLanguages() async {
    try {
      // CORRECTION : Ta capture montre "/langues" et non "/languages"
      final response = await _dio.get('/languages'); 
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
      // Ici, le backend utilise l'anglais selon ta capture
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
  Future<List<dynamic>> fetchLevels() async {
    try {
      // À vérifier si c'est /levels ou /niveaux sur ton swagger
      final response = await _dio.get('/levels'); 
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
}