import 'package:get/get.dart';
import '../../../controller/apps/session_controller.dart';
import '../../../models/partner/referral_model.dart';

class ReferralService {
  static SessionController get _session => Get.find<SessionController>();

  /// Lance une [DioException] en cas d'erreur réseau/serveur, ou une
  /// [Exception] descriptive si la réponse est mal formée — le contrôleur
  /// affiche ensuite ce message réel au lieu d'un état générique.
  static Future<ReferralData> getMyReferral() async {
    final response = await _session.dio.get('/referral/my');

    if (response.data['success'] != true) {
      throw Exception(
          'Réponse serveur inattendue (success=false) : ${response.data}');
    }

    final raw = response.data['data'];
    if (raw == null) {
      throw Exception('Le serveur a renvoyé data=null pour le parrainage.');
    }

    return ReferralData.fromJson(Map<String, dynamic>.from(raw as Map));
  }
}
