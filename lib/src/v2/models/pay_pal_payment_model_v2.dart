part of '../pay_pal_service_v2.dart';


typedef PayPalGetApprovalUrlV2 = Future<PaypalPaymentModelV2> Function();

class PaypalPaymentModelV2 extends PayPalBaseModel {
  final String orderId;
  final String approvalUrl;
  final String accessToken;
  final String? status;

  PaypalPaymentModelV2({
    required this.orderId,
    required this.approvalUrl,
    required super.message,
    required super.key,
    required this.accessToken,
    required super.code,
    this.status,
  });
}