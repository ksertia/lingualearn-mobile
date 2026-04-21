import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../models/etapes/steps_model.dart'; // Notre Master Model

class StepService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstant.baseURl,
    connectTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ))..interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    error: true,
    compact: true,
    maxWidth: 90,
  ));

  // Idéalement, récupère ce token depuis un Prefs ou ton AuthState
  final String _token = "TON_TOKEN_ACTUEL";

  StepService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_token';
        return handler.next(options);
      },
    ));
  }

  /// Récupère le contenu complet d'une étape
  Future<StepData?> getStepContent(String stepId, {String? userId}) async {
    try {
      // On construit les paramètres de requête (queryParameters)
      // Dio s'occupe de transformer ça en ?userId=xxx
      final Map<String, dynamic> queryParams = {};
      if (userId != null) {
        queryParams['userId'] = userId;
      }

      final response = await _dio.get(
        '/steps/$stepId/content',
        queryParameters: queryParams,
      );

      // On utilise le Master Model pour transformer la réponse
      // On passe 'data' directement comme dans ton exemple DiscoverService
      if (response.data['success'] == true) {
        return StepData.fromJson(response.data['data']);
      }
      return null;

    } on DioException catch (e) {
      print("Erreur Dio : ${e.message}");
      return null;
    } catch (e) {
      print("Erreur inattendue : $e");
      rethrow;
    }
  }
}