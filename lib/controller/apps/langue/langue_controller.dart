import 'package:fasolingo/helpers/services/langue/langue_service.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:get/get.dart';

class LanguagesController extends GetxController {
  final LanguageService _languageService = LanguageService();

  RxList<LanguageModel> allLanguages = <LanguageModel>[].obs;
  RxBool isLoading = false.obs;

  Rxn<LanguageModel> selectedLanguage = Rxn<LanguageModel>();

  @override
  void onInit() {
    super.onInit();
    loadAllLanguages(); 
  }

  void selectLanguage(LanguageModel lang) {
    selectedLanguage.value = lang;
  }

  Future<void> loadAllLanguages() async {
    try {
      isLoading(true);
      final result = await _languageService.fetchLanguages();
      allLanguages.assignAll(result);
      print("✅ Controller : ${allLanguages.length} langues prêtes");
    } catch (e) {
      print("❌ Erreur dans le controller : $e");
    } finally {
      isLoading(false);
    }
  }
}