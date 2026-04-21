import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/language_model.dart';
import 'package:fasolingo/models/level_model.dart';
import 'package:fasolingo/models/child_progress_models.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LanguagesService {
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

  static Future<List<LanguageModel>?> getLanguages({
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.get(
        '/languages',
        options: options,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final list = map['data'];
          if (list is List) {
            return list
                .whereType<Map>()
                .map((e) => LanguageModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => LanguageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'GetLanguages');
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<LevelModel>?> getLanguageLevels(
    String languageId, {
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.get(
        '/languages/$languageId/levels',
        options: options,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final inner = map['data'];
          if (inner is Map) {
            final innerMap = Map<String, dynamic>.from(inner);
            final levels = innerMap['levels'];
            if (levels is List) {
              return levels
                  .whereType<Map>()
                  .map((e) => LevelModel.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
            }
          }
        }
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'GetLanguageLevels');
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<ChildProgressResponseModel?> getChildProgress(
    String childId, {
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.get(
        '/languages/children/$childId/progress',
        options: options,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ChildProgressResponseModel.fromJson(data);
        }
        if (data is Map) {
          return ChildProgressResponseModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e, 'GetChildProgress');
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> assignLanguageLevel({
    required String childId,
    required String languageId,
    required String levelId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.post(
        '/languages/children/$childId/languages/$languageId/levels/$levelId/assign',
        data: {
          'childId': childId,
          'languageId': languageId,
          'levelId': levelId,
        },
        options: options,
      );

      return (response.statusCode == 200 || response.statusCode == 201);
    } on DioException catch (e) {
      _handleDioError(e, 'AssignLanguageLevel');
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> assignLanguageToChild({
    required String childId,
    required String languageId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await dio.post(
        '/languages/children/$childId/languages/$languageId/assign',
        data: {
          'childId': childId,
          'languageId': languageId,
        },
        options: options,
      );

      return (response.statusCode == 200 || response.statusCode == 201);
    } on DioException catch (e) {
      _handleDioError(e, 'AssignLanguageToChild');
      return false;
    } catch (_) {
      return false;
    }
  }

  static void _handleDioError(DioException e, String method) {
    Get.log('Network error ($method): ${e.message}');
  }
}
