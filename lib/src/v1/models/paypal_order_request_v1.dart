import 'package:flutter_paypal_payment_checkout_v2/flutter_paypal_payment_checkout_v2.dart';

/// -------------------- ORDER REQUEST --------------------
///
/// Represents a PayPal **Payments API V1** order request.
///
/// This model corresponds to the older V1 endpoint:
/// `POST /v1/payments/payment`
///
/// It uses:
/// - **transactions** (instead of purchase_units)
/// - **redirect_urls**
/// - **payer.payment_method = "paypal"`**
///
/// V1 is still supported but is legacy. V2 should be preferred for new apps.
class PayPalOrderRequestV1 extends PayPalOrderRequestBase {
  /// Defines what PayPal should do with the payment.
  ///
  /// - `"sale"` → immediate capture
  /// - `"authorize"` → authorize only; capture later
  final PayPalOrderIntentV1 intent;

  /// Payer's method. Typically `"paypal"` for browser/SDK redirection flows.
  ///
  /// Example:
  /// ```json
  /// { "payment_method": "paypal" }
  /// ```
  final String paymentMethod;

  /// List of V1-style PayPal transactions.
  ///
  /// Each contains:
  /// - amount
  /// - description
  /// - item_list (optional)
  /// - invoice_number (optional)
  final List<PaypalTransactionV1> transactions;

  /// Optional text shown to the payer during approval.
  ///
  /// Maps to `"note_to_payer"`.
  final String? noteToPayer;

  /// Where PayPal redirects the user **after successful approval**.
  ///
  /// Defaults to the SDK's internal deep link.
  final String returnUrl;

  /// Where PayPal redirects the user **if the payment is cancelled**.
  ///
  /// Defaults to the SDK's internal deep link.
  final String cancelUrl;

  const PayPalOrderRequestV1({
    this.intent = PayPalOrderIntentV1.sale,
    this.paymentMethod = "paypal",
    required this.transactions,
    this.noteToPayer,
    this.returnUrl = defaultReturnURL,
    this.cancelUrl = defaultCancelURL,
  });

  /// Converts this V1 order request into the JSON structure expected by PayPal.
  ///
  /// Example output:
  /// ```json
  /// {
  ///   "intent": "sale",
  ///   "payer": { "payment_method": "paypal" },
  ///   "transactions": [ ... ],
  ///   "note_to_payer": "...",
  ///   "redirect_urls": {
  ///     "return_url": "...",
  ///     "cancel_url": "..."
  ///   }
  /// }
  /// ```
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

  /// True if the request contains no transactions.
  @override
  bool get isEmpty => transactions.isEmpty;

  /// This is a V1 request.
  @override
  bool get isV1 => true;

  /// Not a V2 request.
  @override
  bool get isV2 => false;
}
