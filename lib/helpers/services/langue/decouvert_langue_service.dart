import 'dart:convert';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/langue/decouvert_langue.dart';
import 'package:http/http.dart' as http;


class LanguageService {
  // On utilise ta constante globale
  final String _endpoint = "${AppConstant.baseURl}/discover/languages";

  Future<List<LanguageDiscover>> getDiscoverLanguages() async {
    try {
      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Le corps de la réponse est une liste JSON
        final List<dynamic> jsonData = jsonDecode(response.body);
        
        // On transforme chaque élément en objet LanguageDiscover
        return jsonData.map((item) => LanguageDiscover.fromJson(item)).toList();
      } else {
        // Gestion des erreurs serveurs (404, 500, etc.)
        throw Exception("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      // Gestion des erreurs réseaux ou de parsing
      throw Exception("Erreur de connexion : $e");
    }
  }
}