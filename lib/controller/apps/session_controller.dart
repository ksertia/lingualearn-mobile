import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../helpers/storage/local_storage.dart';

class SessionController extends GetxController {
  var token = "".obs;
  var userId = "".obs; 
  var isLoggedIn = false.obs;
  

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

  @override
  void onReady() {
    super.onReady();
    try {
      final String? storedToken = LocalStorage.getAuthToken();
      final String? storedUserId = LocalStorage.getUserID();

      if (storedToken != null && storedToken.isNotEmpty && storedToken != "null") {
        token.value = storedToken;
      }

      if (storedUserId != null && storedUserId.isNotEmpty) {
        userId.value = storedUserId;
      }

      isLoggedIn.value = token.value.isNotEmpty && userId.value.isNotEmpty;
      if (isLoggedIn.value) {
        print("Session initialisée depuis LocalStorage: userId=${userId.value}");
      } else {
        print("Pas de session locale trouvée");
      }
    } catch (e) {
      print("Erreur lecture LocalStorage en onReady: $e");
    }
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

  void updateUser(UserModel newUser, String newToken) {
    user = newUser;
    userId.value = newUser.id;
    token.value = newToken;   
    isLoggedIn.value = true;
    selectedLanguageId.value = newUser.selectedLanguageId ?? "";
    selectedLevelId.value = newUser.selectedLevelId ?? "";
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
    update();
  }
}