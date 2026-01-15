import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/logger/logger.dart';
import 'package:fasolingo/helpers/remote/api_service.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';

class ProfileService {
  /// ************************* Update Profile Data *************************///
  static Future<Map<String, dynamic>?> updateProfileData(
      {required FormData data}) async {
    try {
      final Response<Map<String, dynamic>?> response = await APIService.put(
          forcedBaseUrl: AppConstant.baseURl_,
          path:
              "${AppConstant.users}/${LocalStorage.getUserID() ?? ""}/${AppConstant.profile}",
          data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      letMeHandleAllErrors(e);
      return null;
    }
  }

  /// ************************* Delete Account Data *************************///
  static Future<Map<String, dynamic>?> deleteAccount(String uUID) async {
    try {
      final Response response = await APIService.delete(
        forcedBaseUrl: AppConstant.baseURl_,
        path: "${AppConstant.users}/$uUID",
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      letMeHandleAllErrors(e);
      return null;
    }
  }

  /// ************************* User Sign Out Data *************************///
  static Future<bool> userSignOut() async {
    try {
      final response =
          await APIService.delete(path: "${AppConstant.tickets}/-me-");
      log("Logout Status==${response.statusCode}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      logD("Error Logout====${e.error}");
      letMeHandleAllErrors(e);
      return false;
    }
  }
}
