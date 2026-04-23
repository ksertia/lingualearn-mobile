import 'package:fasolingo/helpers/services/souscription/sousciption_service.dart';
import 'package:fasolingo/models/souscription/souscription_model.dart';
import 'package:get/get.dart';

class PlanController extends GetxController {
  // Instance du service
  final PlanService _planService = Get.put(PlanService());

  // Variables observables
  var plans = <PlanModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Variables pour l'UI (optionnel mais pratique)
  var selectedPlanId = ''.obs;
  var isYearlySelected = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans(); // Chargement auto des plans à l'initialisation
  }

  /// Récupère les plans depuis le service
  Future<void> fetchPlans() async {
    try {
      isLoading(true);
      errorMessage(''); // Reset de l'erreur

      final fetchedPlans = await _planService.getAllPlans();
      
      // On ne garde que les plans actifs
      plans.value = fetchedPlans.where((p) => p.isActive).toList();
      
      // Sélection par défaut du premier plan "Premium" s'il existe
      if (plans.isNotEmpty) {
        final premiumPlan = plans.firstWhere(
          (p) => p.planName.toLowerCase().contains('prenium'),
          orElse: () => plans.first,
        );
        selectedPlanId.value = premiumPlan.id;
      }

    } catch (e) {
      errorMessage.value = "Impossible de charger les offres d'abonnement.";
      print("🚨 PlanController Error: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Getter pour filtrer les plans selon le toggle mensuel/annuel dans le UI
  List<PlanModel> get filteredPlans => plans.toList();

  /// Change la sélection du plan
  void selectPlan(String id) {
    selectedPlanId.value = id;
  }

  /// Change la période (Mensuel <-> Annuel)
  void togglePeriod(bool isYearly) {
    isYearlySelected.value = isYearly;
  }

  /// Action de souscription
  Future<void> subscribe() async {
    if (selectedPlanId.value.isEmpty) {
      Get.snackbar("Erreur", "Veuillez sélectionner un plan");
      return;
    }

    try {
      // Ici on lancera la logique de paiement
      print("🚀 Tentative de souscription au plan: ${selectedPlanId.value}");
      // Tu peux appeler ton service de paiement ici
    } catch (e) {
      Get.snackbar("Erreur", "Le processus de paiement a échoué");
    }
  }
}