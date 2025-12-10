part of '../paypal_service_v1.dart';

/// -------------------- ORDER REQUEST --------------------

class PayPalOrderRequestV1 extends PayPalOrderRequestBase {
  /// "sale" or "authorize"
  final PayPalOrderIntentV1 intent;

  /// {"payment_method": "paypal"}
  final String paymentMethod;
  final List<PaypalTransactionV1> transactions;
  final String? noteToPayer;
  final String returnUrl;
  final String cancelUrl;

  const PayPalOrderRequestV1({
    this.intent = PayPalOrderIntentV1.sale,
    this.paymentMethod = "paypal",
    required this.transactions,
    this.noteToPayer,
    // required this.returnUrl,
    // required this.cancelUrl,
    this.returnUrl = defaultReturnURL,
    this.cancelUrl = defaultCancelURL,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "intent": intent.value,
      "payer": {
        "payment_method": paymentMethod,
      },
      "transactions": transactions.map((t) => t.toJson()).toList(),
      if (noteToPayer != null) "note_to_payer": noteToPayer,
      "redirect_urls": {
        "return_url": returnUrl,
        "cancel_url": cancelUrl,
      },
    };
  }

  @override
  bool get isEmpty => transactions.isEmpty;

  @override
  bool get isV1 => true;

  @override
  bool get isV2 => false;
}

