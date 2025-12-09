part of '../paypal_service_v1.dart';

typedef PayPalGetApprovalUrlV1 = Future<String> Function();

class PaypalPaymentModelV1 extends PayPalBaseModel {
  final String approvalUrl;
  final String? accessToken, executeUrl;

  PaypalPaymentModelV1({
    required this.approvalUrl,
    required this.executeUrl,
    required this.accessToken,
    required super.message,
    required super.key,
    required super.code,
  });
}