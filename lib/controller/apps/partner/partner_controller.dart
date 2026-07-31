import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../helpers/services/partner/referral_service.dart';
import '../../../models/partner/referral_model.dart';

class PartnerController extends GetxController {
  var isLoading = false.obs;
  var referralData = Rxn<ReferralData>();
  var loadErrorMsg = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchMyReferral();
  }

  Future<void> fetchMyReferral() async {
    try {
      isLoading(true);
      loadErrorMsg.value = null;
      referralData.value = await ReferralService.getMyReferral();
    } on DioException catch (e) {
      loadErrorMsg.value = _dioErrorMsg(e);
    } catch (e) {
      loadErrorMsg.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  String _dioErrorMsg(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connexion trop lente. Vérifie ta connexion internet.';
    }
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return 'Pas de connexion internet. Vérifie ton réseau.';
    }
    final status = e.response?.statusCode ?? 0;
    if (status == 401 || status == 403) return 'Session expirée (code $status).';
    if (status == 404) return 'Aucune donnée de parrainage trouvée (404).';
    if (status >= 500) return 'Erreur serveur (code $status).';
    return 'Impossible de charger vos données de parrainage (code $status).';
  }

  void copyReferralCode() {
    final code = referralData.value?.referralCode;
    if (code == null || code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Copié !',
      'Code copié dans le presse-papiers.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> shareReferralCode() async {
    final code = referralData.value?.referralCode;
    if (code == null || code.isEmpty) return;
    await Share.share(
      'Rejoins-moi sur TiBi et apprends une langue avec moi ! '
      'Utilise mon code de parrainage : $code',
      subject: 'Mon code de parrainage TiBi',
    );
  }
}
