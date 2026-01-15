import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:get/get.dart' hide Response;

/// To handle all the error app wide
void letMeHandleAllErrors(DioException e) {
  switch (e.response?.statusCode) {
    case 500:
      appSnackbar(heading: "", message: "Internal Server Error");
      break;
    case 400:
      appSnackbar(heading: "", message: "Bad Request");
      break;
    case 401:
      Get.offAllNamed("/splash");
      AuthService.isLoggedIn = false;
      LocalStorage.removeLoggedInUser();
      break;
    case 408:
      // appSnackbar(heading: "", message: "Request Timeout");
      Get.offAllNamed("/splash");
      AuthService.isLoggedIn = false;
      LocalStorage.removeLoggedInUser();
      break;
    case 404:
      appSnackbar(heading: "", message: "Page Not Found");
      break;
    case 413:
      appSnackbar(heading: "", message: "Maximum upload size exceeded");
      break;
    default:
      Get.snackbar('Oops!', 'Something went wrong');
      break;
  }
}
