/*
* File : App Theme Notifier (Listener)
* Version : 1.0.0
* */

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/logger/logger.dart';
import 'package:fasolingo/helpers/remote/api_service.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/theme/app_style.dart';
//import 'package:fasolingo/models/charging_stations_wise_charging_connector_response.dart';
import 'package:fasolingo/models/enumaration_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../localizations/language.dart';
import '../utils/app_snackbar.dart';
import 'theme_customizer.dart';

class AppNotifier extends ChangeNotifier {
  AppNotifier();

  EnumerationsModel? enumerationsModel;
  Future<void> init() async {
    changeTheme();
    notifyListeners();
    // _initStomp();
  }

  bool isLoading = false;

  Future<void> getEnum() async {
    try {
      isLoading = true;
      final Response<Map<String, dynamic>?> response = await APIService.get(
        path: "${AppConstant.enumerations}/FR",
        // withOutAuth: true
      );
      if (response.statusCode == 200) {
        enumerationsModel = EnumerationsModel.fromJson(response.data!);
        isLoading = false;
        notifyListeners();
      }
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();
      print('------- error getting enums ----');
      print(e);
      appSnackbar(
        heading: e.message ?? "",
        message: e.message ?? "",
        snackbarState: SnackbarState.warning,
      );
    }
  }

  updateTheme(ThemeCustomizer themeCustomizer) {
    changeTheme();

    notifyListeners();

    LocalStorage.setCustomizer(themeCustomizer);
  }

  Future<void> updateInStorage(ThemeCustomizer themeCustomizer) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("theme_customizer", themeCustomizer.toJSON());
  }

  void changeDirectionality(TextDirection textDirection, [bool notify = true]) {
    if (notify) notifyListeners();
  }

  Future<void> changeLanguage(Language language, {bool notify = true}) async {
    await ThemeCustomizer.changeLanguage(language);
    notifyListeners();
  }

  void changeTheme() {
    logE("THEME===${LocalStorage.getTheme()}");
    AppTheme.theme = AppTheme.getThemeFromThemeMode();
    AppStyle.changeMyTheme();
    notifyListeners();
  }

  ///Socket
  late final StompClient _stompClient;
  bool _isConnected = false;

  final receivedTransactionData = RxMap<String, dynamic>({});
  final Map<String, StompUnsubscribe?> _subscriptions = {};
  //final Map<String, Function(ConnectorsItem)> _wsCallbacks = {};

  void initStomp(String caller) {
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: AppConstant.socketURl,
        onConnect: (frame) {
          _isConnected = true;
          log("Connected to STOMP successfully called from $caller");
        },
        beforeConnect: () async {
          log('Waiting to connect to STOMP socket...');
          await Future.delayed(const Duration(milliseconds: 2000));
          log('Connecting to STOMP socket... called from $caller');
        },
        onWebSocketError: _onWebSocketError,
        onStompError: _onStompError,
        onDisconnect: _onDisconnect,
        onWebSocketDone: () =>
            log('STOMP Socket Connected DONE called from $caller'),
        // onDebugMessage: (String message) => log("SOCKET DEBUG MESSAGE: $message"),
        heartbeatOutgoing: Duration(seconds: 10),
        heartbeatIncoming: Duration(seconds: 10),
        reconnectDelay: Duration(seconds: 5),
      ),
    );
    _stompClient.activate();
  }

  StompClient getStomp() {
    return _stompClient;
  }

  void _onWebSocketError(dynamic error) => log("WebSocket Error: $error");
  void _onStompError(StompFrame frame) => log("STOMP Error: ${frame.body}");
  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    log("STOMP Disconnected");
  }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return (await deviceInfo.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    }
    return null;
  }

  /// Call this from outside (e.g., widget) and pass `transactionId` explicitly
  void subscribeToTransaction(String transactionId, String topic) async {
    if (!_isConnected) {
      log("STOMP not connected yet — delaying subscription.");
      await Future.delayed(Duration(milliseconds: 500)); // simple retry

      // Try again after delay
      if (!_isConnected) {
        log("❌ STOMP still not connected after retry. Cannot subscribe to $topic/$transactionId");
        return;
      }
    }

    final deviceId = await _getDeviceId();
    final clientId = "${LocalStorage.getUserID()}-$deviceId";
    final destination = '/topics/events/$topic/$transactionId';

    log("🟢 Subscribing to WebSocket topic: $destination");

    // Unsubscribe from previous if needed
    _subscriptions[topic]?.call();

    final unsub = _stompClient.subscribe(
      destination: destination,
      headers: {"client-id": clientId},
      callback: (StompFrame frame) {
        log("🟢 Received WebSocket frame for topic $topic");
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          //_handleWebSocketMessage(data);
        } else {
          log("⚠️ Received WebSocket frame with null body");
        }
      },
    );

    _subscriptions[topic] = unsub;
    log("✅ Successfully subscribed to $destination");
  }

  void subscribeToSwapTransactionTopic(
      String transactionId, String topic, Function callback) async {
    if (!_isConnected) {
      log("STOMP not connected yet — delaying subscription.");
      await Future.delayed(Duration(milliseconds: 500)); // simple retry

      // Try again after delay
      if (!_isConnected) {
        log("❌ STOMP still not connected after retry. Cannot subscribe to $topic/$transactionId");
        return;
      }
    }

    final deviceId = await _getDeviceId();
    final clientId = "${LocalStorage.getUserID()}-$deviceId";
    final destination = '/topics/$topic/$transactionId';

    log("🟢 Subscribing to WebSocket topic: $destination");

    // Unsubscribe from previous if needed
    _subscriptions[topic]?.call();

    final unsubscribeFunc = _stompClient.subscribe(
      destination: destination,
      headers: {"client-id": clientId},
      callback: (StompFrame frame) {
        log("🟢 Received WebSocket frame for topic $topic");
        if (frame.body != null) {
          //final data = jsonDecode(frame.body!);
          //_handleWebSocketMessage(data);
          callback(frame.body);
        } else {
          log("⚠️ Received WebSocket frame with null body");
        }
      },
    );
    _subscriptions[topic] = unsubscribeFunc;
    log("✅ Successfully subscribed to $destination");
  }

  // void _handleWebSocketMessage(Map<String, dynamic> data) {
  //   try {
  //     // log("🟢 Raw WebSocket message: $data");
  //
  //     final transaction = data['data']?['transaction'];
  //     if (transaction != null) {
  //       receivedTransactionData.value = transaction;
  //       // log("🟢 Received Transaction Data: ${transaction['status']}");
  //
  //       // Call all registered callbacks with the transaction data
  //       _wsCallbacks.forEach((stationUuid, callback) {
  //         try {
  //           final connectorData = transaction['chargingConnector'];
  //           if (connectorData != null) {
  //             // Create a ConnectorsItem from the transaction data
  //             final connectorItem = ConnectorsItem(
  //               uuid: connectorData['uuid'],
  //               serial: connectorData['chargingStation']?['serial'],
  //               type: connectorData['type'],
  //               powerInKw: connectorData['powerInKw'] != null
  //                   ? int.tryParse(connectorData['powerInKw'].toString())
  //                   : null,
  //               temperature: connectorData['temperature']?.toString(),
  //               // Add other required fields as needed
  //             );
  //
  //             log("🟢 Calling callback for swap_station $stationUuid with connector ${connectorItem.uuid}");
  //             callback(connectorItem);
  //           }
  //         } catch (e) {
  //           log("❌ Error in WebSocket callback for $stationUuid: $e");
  //         }
  //       });
  //
  //       notifyListeners();
  //     } else {
  //       log("⚠️ No transaction data in WebSocket message");
  //     }
  //   } catch (e, s) {
  //     log("❌ Error parsing WebSocket message: $e\n$s");
  //   }
  // }

  // void setWebSocketCallback(
  //     String connectorUuid, Function(ConnectorsItem) callback) {
  //   _wsCallbacks[connectorUuid] = callback;
  // }
  //
  // void removeWebSocketCallback(String stationUuid) {
  //   _wsCallbacks.remove(stationUuid);
  //   // debugPrint("[WebSocket] Removed callback for $stationUuid");
  // }

  bool get isWebSocketConnected => _isConnected;

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }
}
