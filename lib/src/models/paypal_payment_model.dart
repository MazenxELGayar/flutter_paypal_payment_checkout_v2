import 'package:flutter_paypal_payment_checkout_v2/src/models/shared_models.dart';

typedef PayPalGetApprovalUrl = Future<PaypalPaymentModel> Function();

class PaypalPaymentModel extends PayPalBaseModel {
  final String? orderId;
  final String approvalUrl;
  final String returnURL;
  final String cancelURL;
  final String? status;
  final String? accessToken;
  final String? executeUrl;

  PaypalPaymentModel({
    required this.approvalUrl,
    required this.executeUrl,
    required this.accessToken,
    this.returnURL = defaultReturnURL,
    this.cancelURL = defaultCancelURL,
    required super.message,
    required super.key,
    required super.code,
    required this.status,
    required this.orderId,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "approvalUrl": approvalUrl,
      "executeUrl": executeUrl,
      "accessToken": accessToken,
      "returnURL": returnURL,
      "cancelURL": cancelURL,
      "status": status,
      "message": message,
      "key": key,
      "code": code,
    };
  }
}
