import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../helpers/storage/local_storage.dart';

class SessionController extends GetxController {
  var token = "".obs;
  var userId = "".obs; 
  var isLoggedIn = false.obs;
  
  // --- AJOUTS CRITIQUES ICI ---
  // On utilise des RxString pour que le Splash puisse les observer facilement
  var selectedLanguageId = "".obs;
  var selectedLevelId = "".obs;

  UserModel? user;
  bool vientDeLaDecouverte = false;

  late Dio dio;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstant.baseURl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String? storedToken = LocalStorage.getAuthToken();
        if (storedToken != null && storedToken.isNotEmpty && storedToken != "null") {
          options.headers['Authorization'] = 'Bearer $storedToken';
        }
        return handler.next(options);
      },
    ));
  }

  // Fonction appelée lors du Login OU du Splash (quand le profil est chargé)
  void updateUser(UserModel newUser, String newToken) {
    user = newUser;
    userId.value = newUser.id;
    token.value = newToken;   
    isLoggedIn.value = true;
    
    // --- ON SYNCHRONISE LES CHOIX DU SERVEUR ---
    // On convertit les String? du modèle en "" (vide) si null pour les RxString
    selectedLanguageId.value = newUser.selectedLanguageId ?? "";
    selectedLevelId.value = newUser.selectedLevelId ?? "";
    
    print("✅ SESSION MAJ : Langue = ${selectedLanguageId.value}, Niveau = ${selectedLevelId.value}");
    update(); 
  }

  bool hasValidSession() {
    return userId.value.isNotEmpty && token.value.isNotEmpty;
  }

  void clearSession() {
    user = null;
    userId.value = "";
    token.value = "";
    isLoggedIn.value = false;
    selectedLanguageId.value = "";
    selectedLevelId.value = "";
    print("📴 Session vidée");
    update();
  }
}