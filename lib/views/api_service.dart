import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/learning_path_model.dart';

class ApiService {
  static const String baseUrl = 'https://213.32.120.11:4000';

  // Récupérer tous les parcours
  static Future<List<LearningPathModel>> getLearningPaths() async {
    try {
      var url = Uri.parse('$baseUrl/api/v1/learning-paths');
      var response = await http.get(url, headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        return jsonData.map((e) => LearningPathModel.fromJson(e)).toList();
      } else {
        print('Erreur API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception API: $e');
      return [];
    }
  }
}
