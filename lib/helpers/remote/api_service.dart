import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/logger/logger.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:flutter/foundation.dart';


dynamic CURR_STATION = null;
dynamic CURR_BIKE, CURR_TRANSACTION;

/// DIO interceptor to add the authentication token
InterceptorsWrapper addAuthToken({String authTokenHeader = 'Authorization'}) =>
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers.addAll(<String, dynamic>{
          authTokenHeader: "Bearer ${LocalStorage.getAuthToken()}",
        });
        handler.next(options); //continue
      },
    );

/// Dio interceptor to encrypt the request body
InterceptorsWrapper encryptBody() => InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        final String method = options.method.toUpperCase();

        if (options.headers['encrypt'] as bool) {
          switch (method) {
            case 'POST':
            case 'PUT':
            case 'PATCH':
              logW('encrypting $method method');
              if (options.data.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>') {
                logI('Data will be encrypted before sending request');
                options.data = <String, dynamic>{};
              } else {
                logI('Skipping encryption for ${options.data.runtimeType} type');
              }

              break;
            default:
              logWTF('Skipping encryption for $method method');
              break;
          }
        }
        handler.next(options); //continue
      },
    );

/// API service of the application. To use Get, POST, PUT and PATCH rest methods
class APIService {
  static final Dio _dio = Dio();
  static final Dio _dioWithoutAuth = Dio();

  static late String _prodBaseApiUrl;
  static late String _devBaseApiUrl;

  static String get _baseUrl => kReleaseMode ? _prodBaseApiUrl : _devBaseApiUrl;

  /// Initialize the API service
  static void initializeAPIService({
    required String devBaseUrl,
    required String prodBaseUrl,
    bool encryptData = false,
    String authHeader = 'Authorization',
    String xAPIKeyHeader = 'x-api-key',
    String xAPIKeyValue = 'x-api-key',
  }) {
    _devBaseApiUrl = devBaseUrl;
    _prodBaseApiUrl = prodBaseUrl;

    _dio.options.headers.addAll(
        <String, dynamic>{"Content-Type": "application/json", "Accept": "*/*"});
    _dioWithoutAuth.options.headers.addAll(
        <String, dynamic>{"Content-Type": "application/json", "Accept": "*/*"});
    /*if (UserProvider.isLoggedIn) {
      _dio.options.headers.addAll(<String, dynamic>{
        authHeader: UserProvider.authToken,
      });
    }*/
    _dio.interceptors.add(addAuthToken(authTokenHeader: authHeader));
    //Add interceptor for encryption layer
    // if (encryptData) {
    //   logI('Data will be encrypted for POST / PUT / PATCH');
    //   _dio.interceptors.add(encryptBody());
    // }
    // if (kDebugMode) {
    //   //Add interceptor for console logs
    //   _dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //   ));
    //   _dioWithoutAuth.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //   ));
    // }

    // _restClient.getTasks();
  }

  /// GET rest API call
  /// Used to get data from backend
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>> get({
    required String path,
    Map<String, dynamic>? params,
    bool encrypt = false,
    bool withOutAuth = false,
    String? forcedBaseUrl,
  }) async =>
      withOutAuth
          ? _dioWithoutAuth.get<Map<String, dynamic>?>(
              (forcedBaseUrl ?? _baseUrl) + path,
              queryParameters: params,
              options: Options(headers: <String, dynamic>{"Accept": "*/*"}),
            )
          : _dio.get<Map<String, dynamic>?>(
              (forcedBaseUrl ?? _baseUrl) + path,
              queryParameters: params,
              options: Options(headers: <String, dynamic>{"Accept": "*/*"}),
            );

  // static Future<Response<Map<String, dynamic>?>> get2({
  //   required String path,
  //   Map<String, dynamic>? params,
  //   bool encrypt = false,
  //   bool withOutAuth = false,
  //   String? forcedBaseUrl,
  // }) async =>
  //     withOutAuth
  //         ? _dioWithoutAuth.get<Map<String, dynamic>?>(
  //       AppConstant.baseURl1 + path,
  //       queryParameters: params,
  //       options: Options(headers: <String, dynamic>{"Accept": "*/*"}),
  //     )
  //         : _dio.get<Map<String, dynamic>?>(
  //       AppConstant.baseURl1 + path,
  //       queryParameters: params,
  //       options: Options(headers: <String, dynamic>{"Accept": "*/*"}),
  //     );

  static Future<Response<Map<String, dynamic>?>> resourceGet({
    required String path,
    Map<String, dynamic>? params,
    bool encrypt = false,
    String? forcedBaseUrl,
  }) async =>
      _dio.request(
        (forcedBaseUrl ?? _baseUrl) + path,
        queryParameters: params,
        options: Options(headers: <String, dynamic>{"Accept": "*/*"}),
      );

  static Future<Uint8List> getImage({required String path}) async {
    final response = await _dio.get(
      (_baseUrl) + path,
      options: Options(
        headers: {
          'Accept': '*/*',
        },
        responseType: ResponseType.bytes, // Ensure the response type is bytes
      ),
    );
    logV("Image Response====${response.data}");
    logV("Image Response RuntimeType====${response.data.runtimeType}");
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load image');
    }
  }

  /// POST rest API call
  /// Used to send any data to server and get a response
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>> post({
    required String path,
    FormData? data,
    Object? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    Map<String, dynamic>? headers,
    String? forcedBaseUrl,
    // Function(double progress)? callback,
  }) async =>
      _dio.post<Map<String, dynamic>?>((forcedBaseUrl ?? _baseUrl) + path,
          data: mapData ?? data,
          queryParameters: params,
          options: Options(
              headers: headers ??
                  <String, dynamic>{
                    'Content-Type': "application/json",
                    "Accept": "*/*",
                  }));

  static Future<Response<Map<String, dynamic>?>> postWithoutAth({
    required String path,
    FormData? data,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    Map<String, dynamic>? headers,
    String? forcedBaseUrl,
    // Function(double progress)? callback,
  }) async =>
      _dioWithoutAuth.post<Map<String, dynamic>?>(
          (forcedBaseUrl ?? _baseUrl) + path,
          data: mapData ?? data,
          queryParameters: params,
          options: Options(
              headers: headers ??
                  <String, dynamic>{
                    'Content-Type': "multipart/form-data",
                    "Accept": "*/*",
                  }));

  /// PUT rest API call
  /// Usually used to create new record
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>> put({
    required String path,
    FormData? data,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.put<Map<String, dynamic>?>(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: mapData ?? data,
        queryParameters: params,
        options: Options(headers: <String, dynamic>{
          // 'encrypt': encrypt,
        }),
      );

  /// PATCH rest API call
  /// Usually used to update any record
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>> patch({
    required String path,
    FormData? data,
    Map<String, dynamic>? params,
    dynamic mapData,
    Map<String, dynamic>? headers,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.patch<Map<String, dynamic>?>(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: mapData ?? data,
        queryParameters: params,
        options: Options(
            headers: headers ??
                <String, dynamic>{
                  'Content-Type': "multipart/form-data",
                  "Accept": "*/*",
                }),
      );

  static Future<Response<T?>> delete<T>({
    required String path,
    FormData? data,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.delete(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: mapData ?? data,
        queryParameters: params,
      );


}
