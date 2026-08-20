import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../helpers/services/contents/content_service.dart';
import '../../../models/contents/content_model.dart';

class StepController extends GetxController {
  final ContentService _contentService = ContentService();

  var isLoading = false.obs;
  var contents = <ContentModel>[].obs;
  var currentContentIndex = 0.obs;
  var loadErrorMsg = Rxn<String>();

  Future<void> loadContents(String subThemeId, {int initialIndex = 0}) async {
    try {
      isLoading(true);
      loadErrorMsg.value = null;
      currentContentIndex(0);

      final list = await _contentService.getContentsBySubTheme(subThemeId);
      list.sort((a, b) => a.index.compareTo(b.index));
      contents.value = list;
      if (list.isNotEmpty) {
        currentContentIndex.value = initialIndex.clamp(0, list.length - 1);
      }
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
    if (status == 404) return 'Sous-thème introuvable (404).';
    if (status >= 500) return 'Erreur serveur (code $status).';
    return 'Impossible de charger le contenu (code $status) : ${e.response?.data}';
  }

  void nextContent() {
    if (currentContentIndex.value < contents.length - 1) {
      currentContentIndex.value++;
    } else {
      // TODO: appeler l'endpoint de complétion du sous-thème une fois
      // disponible côté backend.
      Get.back(result: true);
    }
  }

  void previousContent() {
    if (currentContentIndex.value > 0) {
      currentContentIndex.value--;
    }
  }
}
