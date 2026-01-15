import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';

class ReportProblemService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstant.baseURl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  Future<void> sendReport({
    required String token,
    required String type,
    required String description,
    required String collectorId,
    required String agencyId,
    List<File>? photos,
  }) async {
    final formData = FormData();
    formData.fields
      ..add(MapEntry('type', type))
      ..add(MapEntry('description', description))
      ..add(MapEntry('collectorId', collectorId))
      ..add(MapEntry('agencyId', agencyId));

    if (photos != null && photos.isNotEmpty) {
      for (final file in photos) {
        formData.files.add(
          MapEntry(
            'photos',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    }
    print('============ DEBUG ENVOI ============');
    for (final field in formData.fields) {
      print('Champ: ${field.key} = ${field.value}');
    }
    for (final file in formData.files) {
      print('Fichier: ${file.key} -> ${file.value.filename}');
    }
    try {
      final response = await _dio.post(
        '/reports',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Erreur serveur : ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print(' Problème réseau ou serveur injoignable');
      }
      print('=======================================');
      rethrow;
    } catch (e) {
      print(e);
      print('=======================================');
      rethrow;
    }
  }
}
