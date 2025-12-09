part of '../pay_pal_service_v2.dart';

/// -------------------- ORDER REQUEST --------------------

class PayPalOrderRequestV2 {
  final PayPalOrderIntentV2 intent;
  final PayPalPaymentSourceV2 paymentSource;
  final List<PayPalPurchaseUnitV2> purchaseUnits;

  PayPalOrderRequestV2({
    this.intent = PayPalOrderIntentV2.capture,
    required this.paymentSource,
    required this.purchaseUnits,
  });

  Map<String, dynamic> toJson() => {
        "intent": intent.value,
        "payment_source": paymentSource.toJson(),
        "purchase_units": purchaseUnits.map((e) => e.toJson()).toList(),
      };
}
