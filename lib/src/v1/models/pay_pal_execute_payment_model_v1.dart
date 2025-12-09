part of '../paypal_service_v1.dart';
class PayPalExecutePaymentModelV1 extends PayPalBaseModel {
  final dynamic data; // PayPal response body

  PayPalExecutePaymentModelV1({
    required this.data,
    required super.message,
    required super.key,
    required super.code,
  });
}