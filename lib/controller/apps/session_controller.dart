import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:tibi/helpers/constant/app_constant.dart';
import 'package:flutter/foundation.dart';
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
  bool _isRefreshing = false;

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
    } catch (e) {
      // Erreur lecture LocalStorage — session non restaurée
    }
  }

  void _initDio() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstant.baseURl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    if (!kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final storedToken = LocalStorage.getAuthToken();
        if (storedToken != null && storedToken.isNotEmpty && storedToken != "null") {
          options.headers['Authorization'] = 'Bearer $storedToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // Ignorer les erreurs non-401 et les retentatives déjà en cours
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }
        // Éviter la récursion si c'est déjà une requête de refresh
        if (error.requestOptions.extra['_isRetry'] == true) {
          _forceLogout();
          return handler.reject(error);
        }
        // Si un refresh est déjà en cours, on rejette sans relancer
        if (_isRefreshing) {
          return handler.reject(error);
        }

        final refreshToken = LocalStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _forceLogout();
          return handler.reject(error);
        }

        _isRefreshing = true;
        try {
          // Dio séparé pour ne pas boucler sur l'intercepteur principal
          final refreshDio = Dio(BaseOptions(
            baseUrl: AppConstant.baseURl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));
          if (!kIsWeb) {
            refreshDio.httpClientAdapter = IOHttpClientAdapter(
              createHttpClient: () {
                final client = HttpClient();
                client.badCertificateCallback = (cert, host, port) => true;
                return client;
              },
            );
          }

          final res = await refreshDio.post(
            '/auth/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          if (res.statusCode == 200 && res.data != null) {
            // Réponse plate : {success, accessToken, refreshToken, expiresIn}
            // — pas de wrapper "data" comme sur les autres endpoints.
            final data = res.data;
            final newAccessToken = data['accessToken'] as String?;
            final newRefreshToken = data['refreshToken'] as String?;

            if (newAccessToken == null || newAccessToken.isEmpty) {
              _forceLogout();
              return handler.reject(error);
            }

            await LocalStorage.setAuthToken(newAccessToken);
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await LocalStorage.setRefreshToken(newRefreshToken);
            }
            token.value = newAccessToken;

            // Rejouer la requête originale avec le nouveau token
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra['_isRetry'] = true;
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } else {
            // Refresh token explicitement rejeté par le serveur → déconnexion.
            // Toute autre réponse (erreur serveur ponctuelle) ne doit pas
            // faire perdre la session.
            if (res.statusCode == 401 || res.statusCode == 403) {
              _forceLogout();
            }
            return handler.reject(error);
          }
        } on DioException catch (refreshError) {
          // Ne déconnecter que si le serveur a explicitement invalidé le
          // refresh token. Une coupure réseau ou un timeout pendant le
          // refresh ne doit pas forcer une reconnexion.
          final refreshStatus = refreshError.response?.statusCode;
          if (refreshStatus == 401 || refreshStatus == 403) {
            _forceLogout();
          }
          return handler.reject(error);
        } catch (_) {
          return handler.reject(error);
        } finally {
          _isRefreshing = false;
        }
      },
    ));
  }

  void _forceLogout() {
    LocalStorage.removeLoggedInUser();
    clearSession();
    Get.offAllNamed('/login');
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