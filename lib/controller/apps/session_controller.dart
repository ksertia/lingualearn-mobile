import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../helpers/storage/local_storage.dart';

class SessionController extends GetxController {
  var token = "".obs;
  var userId = "".obs; 
  var isLoggedIn = false.obs;
  var langueChoisie = "".obs;

  UserModel? user;
  bool vientDeLaDecouverte = false;

  // 1. Déclarer Dio proprement
  late Dio dio;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  // 2. Initialiser Dio avec l'URL de base et le Token
  void _initDio() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstant.baseURl,  // Ton URL de base
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Cet intercepteur ajoute le token automatiquement à chaque appel
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String? storedToken = LocalStorage.getAuthToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $storedToken';
        }
        return handler.next(options);
      },
    ));
  }

  // Fonction appelée lors du Login réussi
  void updateUser(UserModel newUser, String newToken) {
    user = newUser;
    userId.value = newUser.id;
    token.value = newToken;   
    isLoggedIn.value = true;
    
    print(" ✅ SESSION INITIALISÉE : ID = ${userId.value}");
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
    print("📴 Session vidée");
    update();
  }
}