import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:fasolingo/helpers/constant/app_constant.dart';
import '../../models/client_model.dart';
import '../storage/local_storage.dart';

class ClientService {
  Future<ClientModel> getClientById(String clientId) async {
    //final url = Uri.parse('${AppConstant.baseURl}/collecte/scan?id=$clientId');

    // ====================== fasolingovie version améliorer à retenir =====================
    final url = Uri.parse('${AppConstant.baseURl}/collecte/scan')
        .replace(queryParameters: {'id': clientId});

    final token = LocalStorage.getAuthToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print('==================JSON reçu client : $jsonBody');
        if (jsonBody['client'] != null) {
          return ClientModel.fromJson(jsonBody['client']);
        } else {
          throw Exception(
              '============== Réponse invalide : champ "client" manquant dans la réponse.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token invalide ou expiré. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur ${response.statusCode} : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau ou parsing : $e');
    }
  }

  Future<void> validateCollecte(String clientId, String status) async {
    final url = Uri.parse('${AppConstant.baseURl}/collecte/scan/validate');
    final rawToken = LocalStorage.getAuthToken();
    final token = rawToken?.trim();

    if (token == null || token.isEmpty) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }
    final trimmedClientId = clientId.trim();
    if (trimmedClientId.isEmpty) {
      throw Exception('clientId vide');
    }
    print('========= Envoi validation : clientId="$trimmedClientId", status="$status"');
    print('================ Token utilisé : "$token"');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'clientId': trimmedClientId,
          'status': status,
        }),
      );
      print('Code HTTP : ${response.statusCode}');
      print('Réponse validation : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonBody = json.decode(response.body);
          print('Validation collecte réussie : $jsonBody');
        } catch (e) {
          print('⚠ Erreur de parsing JSON : $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Collecteur non authentifié ou token invalide.');
      } else if (response.statusCode == 400) {
        throw Exception('Requête invalide : ${response.body}');
      } else {
        throw Exception('Erreur ${response.statusCode} : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau ou parsing : $e');
    }
  }
}
