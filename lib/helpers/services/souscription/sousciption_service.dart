import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/souscription/souscription_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_package;

class PlanService extends GetxService {
  final SessionController _session = Get.find<SessionController>();

  /// Récupère tous les plans via l'URL constante
  Future<List<PlanModel>> getAllPlans() async {
    try {
      // Construction de l'URL complète
      final String fullUrl = "${AppConstant.baseURl}/subscription-plans";

      final response = await _session.dio.get(fullUrl);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => PlanModel.fromJson(json)).toList();
      } else {
        throw Exception("Erreur serveur : ${response.statusCode}");
      }
    } on dio_package.DioException catch (e) {
      // Gestion des erreurs Dio avec ton interface Session
      String errorMsg = e.response?.data['message'] ?? "Erreur de connexion au serveur";
      print("🚨 Erreur PlanService: $errorMsg");
      rethrow;
    } catch (e) {
      print("🚨 Erreur inattendue: $e");
      rethrow;
    }
  }

  /// Méthode pour vérifier si l'utilisateur a un abonnement actif
  Future<Map<String, dynamic>?> checkCurrentSubscription() async {
    try {
      final response = await _session.dio.get("${AppConstant.baseURl}/subscriptions/my-status");
      return response.data;
    } catch (e) {
      return null;
    }
  }
}