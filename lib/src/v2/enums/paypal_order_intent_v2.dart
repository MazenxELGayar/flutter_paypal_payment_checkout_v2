/// Defines the PayPal **Orders V2 intent**.
///
/// Maps to:
/// `intent: "CAPTURE"` or `"AUTHORIZE"`
///
/// - **CAPTURE**
///   Immediately captures payment once approved.
///
/// - **AUTHORIZE**
///   Places a hold on the funds. Must later use:
///   `POST /v2/payments/authorizations/{id}/capture`
enum PayPalOrderIntentV2 {
  capture,
  authorize;

  /// Converts enum → PayPal API string.
  String get value {
    switch (this) {
      case PayPalOrderIntentV2.capture:
        return "CAPTURE";
      case PayPalOrderIntentV2.authorize:
        return "AUTHORIZE";
    }
  }
}
