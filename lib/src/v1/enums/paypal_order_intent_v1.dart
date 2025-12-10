/// Represents the `intent` field used in the PayPal **Payments API V1**.
///
/// Determines what PayPal should do with the payment once approved.
///
/// - **sale**
///   Immediate payment capture. Funds are transferred instantly once the user
///   approves the payment.
///
/// - **authorize**
///   Places a hold on the funds. The merchant must later capture the payment
///   using the authorization ID.
///
/// These values map directly to PayPal’s V1 field:
/// ```json
/// { "intent": "sale" }
/// ```
enum PayPalOrderIntentV1 {
  /// `"sale"` — Immediately captures the payment.
  sale,

  /// `"authorize"` — Only authorizes the payment; must be captured later.
  authorize;

  /// Returns the exact string value expected by the PayPal V1 API.
  String get value {
    switch (this) {
      case PayPalOrderIntentV1.sale:
        return "sale";
      case PayPalOrderIntentV1.authorize:
        return "authorize";
    }
  }
}
