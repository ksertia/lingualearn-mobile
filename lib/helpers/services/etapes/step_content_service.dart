import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../models/etapes/steps_model.dart'; // Notre Master Model

class StepService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstant.baseURl,
    connectTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ))
    ..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

  StepService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorage.getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

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
    } on DioException catch (e) {
      print("Erreur Dio : ${e.message}");
      return null;
    } catch (e) {
      print("Erreur inattendue : $e");
      return null;
    }
  }
}
