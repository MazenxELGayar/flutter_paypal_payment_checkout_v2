import 'package:flutter_paypal_payment_checkout_v2/flutter_paypal_payment_checkout_v2.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/enums/pay_pal_order_intent_v2.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/models/pay_pal_experience_context_v2.dart';
import 'package:flutter_paypal_payment_checkout_v2/src/v2/models/pay_pal_purchase_unit_v2.dart';

/// -------------------- ORDER REQUEST --------------------

class PayPalOrderRequestV2 extends PayPalOrderRequestBase {
  final PayPalOrderIntentV2 intent;
  final PayPalPaymentSourceV2 paymentSource;
  final List<PayPalPurchaseUnitV2> purchaseUnits;

  PayPalOrderRequestV2({
    this.intent = PayPalOrderIntentV2.capture,
    required this.paymentSource,
    required this.purchaseUnits,
  });

  @override
  Map<String, dynamic> toJson() => {
        "intent": intent.value,
        "payment_source": paymentSource.toJson(),
        "purchase_units": purchaseUnits.map((e) => e.toJson()).toList(),
      };

  @override
  bool get isEmpty => purchaseUnits.isEmpty;

  @override
  bool get isV1 => false;

  @override
  bool get isV2 => true;
}
