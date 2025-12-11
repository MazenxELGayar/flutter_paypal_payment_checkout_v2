import 'package:dartz/dartz.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/models/paypal_shared_models.dart';

/// A function signature that returns a `PaypalPaymentModel`.
///
/// This typedef is used by services that request an approval URL from PayPal
/// during the order creation or payment setup flow.
typedef PayPalGetCheckOutUrl = Future<Either<PayPalErrorModel,PaypalPaymentModel>> Function();

/// Represents all essential PayPal payment details required by the client
/// to proceed with the approval, capture, or final execution flow.
///
/// This model is typically returned after creating a PayPal order and contains:
/// - The approval URL for redirecting the user to PayPal.
/// - The `orderId` needed for capture.
/// - Optional `executeUrl` / `accessToken` (used in older PayPal V1 flows).
/// - Return and cancel URLs.
/// - Status information and common base error fields.
///
/// Inherits:
/// - `message`, `key`, `code` from `PayPalBaseModel` for standardized error handling.
class PaypalPaymentModel extends PayPalBaseModel {
  /// The unique PayPal order ID returned after creating the order.
  final String? orderId;

  /// The URL where the user should be redirected to approve the payment.
  final String approvalUrl;

  /// Return URL where PayPal will redirect after successful approval.
  final String returnURL;

  /// Cancel URL where PayPal redirects if the user cancels the payment.
  final String cancelURL;

  /// Optional PayPal order/payment status.
  final String? status;

  /// Optional OAuth access token (commonly used in PayPal V1 integrations).
  final String? accessToken;

  /// Optional execute URL used in legacy PayPal execution flow (V1 only).
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

  /// Converts this model to JSON for logging or local persistence.
  ///
  /// Useful when caching the payment state or debugging PayPal responses.
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
