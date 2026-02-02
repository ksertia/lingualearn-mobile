import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/langue/langue_model.dart'; 

class LanguageService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstant.baseURl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<LanguageModel>> fetchLanguages() async {
    try {
      final response = await _dio.get('/languages');

      print("📡 URL Appellée : ${_dio.options.baseUrl}/languages");
      print("📡 Code Status : ${response.statusCode}");

      if (response.statusCode == 200) {
        final List? listData = response.data['data'];
        
        if (listData == null) return [];

        print("✅ Langues brutes reçues : ${listData.length}");

        return listData
            .where((item) => item != null && item is Map)
            .map<LanguageModel>((item) => LanguageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      print("❌ Erreur Dio (${e.response?.statusCode}) : ${e.response?.data}");
      return [];
    } catch (e) {
      print("❌ Erreur inattendue : $e");
      return [];
    }
  }
}