import 'package:dio/dio.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:get/get.dart';
import '../../controller/apps/session_controller.dart';


class ModuleService {
  static final session = Get.find<SessionController>();

  static Future<List<ModuleModel>> getAllModules() async {
    try {
      final response = await session.dio.get('/modules');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          // C'est ICI qu'on transforme la liste de JSON en liste d'objets Dart
          return data.map<ModuleModel>((m) => ModuleModel.fromJson(m as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      print("🚨 Erreur Service : $e");
      return [];
    }
  }
}