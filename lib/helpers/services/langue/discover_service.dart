import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/langue/decouverte_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DiscoverService {
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

  final String _token = "TON_TOKEN_ACTUEL"; 

  DiscoverService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_token';
        return handler.next(options);
      },
    ));
  }

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