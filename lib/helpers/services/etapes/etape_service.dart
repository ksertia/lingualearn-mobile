import 'dart:convert';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:http/http.dart' as http;

class StepsService {
  // On utilise ta constante globale ici
  final String baseUrl = AppConstant.baseURl;

  Future<List<StepModel>> getSteps({
    required String token,
    required String languageId,
    required String levelId,
    required String moduleId,
    required String pathId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/languages/$languageId/levels/$levelId/modules/$moduleId/paths/$pathId/steps'
      );

      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Vérification du flag "success" renvoyé par ton API
        if (responseData['success'] == true) {
          final List<dynamic> stepsList = responseData['data']['steps'];
          
          // Transformation du JSON en liste d'objets StepModel
          return stepsList.map((json) => StepModel.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? "Échec de la récupération des étapes");
        }
      } else {
        // Gestion des erreurs serveurs (401, 404, 500, etc.)
        throw Exception("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      // Log de l'erreur pour le debug
      print("Erreur dans StepsService : $e");
      rethrow; // On renvoie l'erreur pour qu'elle soit gérée par le Controller
    }
  }
}