import 'package:dio/dio.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:get/get.dart';

class PaymentService extends GetxService {
  final SessionController _session = Get.find<SessionController>();

  /// Étape 1 : initier le paiement mobile money
  /// Retourne paymentRequestId, amount, currency, otpExpiresAt
  Future<Map<String, dynamic>> initiatePayment({
    required String planId,
    required String paymentMethod, // "orange_money" | "moov_money" | "coris_money"
    required String phoneNumber,
    String billingCycle = 'monthly',
  }) async {
    final userId = _session.userId.value;
    final response = await _session.dio.post(
      '${AppConstant.baseURl}/payment/initiate',
      data: {
        'userId': userId,
        'planId': planId,
        'billingCycle': billingCycle,
        'paymentMethod': paymentMethod,
        'phoneNumber': phoneNumber,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Étape 2 : confirmer avec le code OTP
  /// Retourne message + subscription
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentRequestId,
    required String otpCode,
  }) async {
    final response = await _session.dio.post(
      '${AppConstant.baseURl}/payment/confirm',
      data: {
        'paymentRequestId': paymentRequestId,
        'otpCode': otpCode,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
