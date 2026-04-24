import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParcoursSelectionController extends GetxController {
  late String moduleId;
  late String userId;
  late String languageId;
  late String levelId;
  late bool showAllPaths;

  RxBool isLoading = false.obs;
  RxList<dynamic> items = <dynamic>[].obs;
  RxInt currentPage = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();

    moduleId = "";
    userId = "";
    languageId = "";
    levelId = "";
    showAllPaths = false;

    try {
      if (Get.arguments is Map) {
        final Map args = Get.arguments as Map;
        moduleId = (args['moduleId'] ?? "").toString();
        userId = (args['userId'] ?? "").toString();
        languageId = (args['languageId'] ?? "").toString();
        levelId = (args['levelId'] ?? "").toString();
        showAllPaths = args['showAllPaths'] == true || moduleId.isEmpty;
      } else if (Get.arguments != null) {
        moduleId = Get.arguments.toString();
        showAllPaths = moduleId.isEmpty;
      } else {
        showAllPaths = true;
      }
    } catch (e) {
      moduleId = "";
      showAllPaths = true;
    }

    fetchPaths();
  }

  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  Future<void> fetchPaths() async {
    try {
      isLoading.value = true;
      items.clear();

      if (showAllPaths) {
        final modules = await ModuleService.getAllModules();
        if (modules.isNotEmpty) {
          modules.sort((a, b) => a.index.compareTo(b.index));
          for (final module in modules) {
            items.add(module);
            final paths =
                await LearningPathService.getPathsBySpecificModule(module.id);
            if (paths.isNotEmpty) {
              paths.sort((a, b) => a.index.compareTo(b.index));
              items.addAll(paths);
            }
          }
        }
      } else {
        if (moduleId.isNotEmpty && moduleId != "null") {
          final results =
              await LearningPathService.getPathsBySpecificModule(moduleId);
          if (results.isNotEmpty) {
            results.sort((a, b) => a.index.compareTo(b.index));
            items.assignAll(results);
          }
        }
      }
    } catch (e) {
      // silent
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async => fetchPaths();

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
