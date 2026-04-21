import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:fasolingo/model/children_response_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ChildrenService {
  static final Dio dio = Dio(
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

  static Future<List<ChildModel>?> getMyChildren({
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.get(
        '/users/my-children',
        options: options,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          return ChildrenResponseModel.fromJson(data).data;
        }

        if (data is Map) {
          return ChildrenResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          ).data;
        }
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'GetMyChildren');
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createChild(
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      payload.removeWhere((key, value) => value == null);

      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.post(
        '/auth/children',
        data: payload,
        options: options,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
        return <String, dynamic>{'data': response.data};
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'CreateChild');
      return null;
    } catch (_) {
      return null;
    }
  }

  static void _handleDioError(DioException e, String method) {
    print(
        '=================== Erreur réseau $method ===================');
    print('Type : ${e.type}');
    print('Message : ${e.message}');
    if (e.response != null) {
      print('Code de retour : ${e.response?.statusCode}');
      print("Données d'erreur : ${e.response?.data}");
    }
    print('==============================================================\n');
  }
}
