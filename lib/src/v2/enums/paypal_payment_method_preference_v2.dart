/// Controls how strictly PayPal enforces immediate payment.
///
/// Maps to:
/// `application_context.payment_method.preference`
///
/// - **IMMEDIATE_PAYMENT_REQUIRED**
///   Buyer must pay immediately (recommended for most flows).
///
/// - **UNRESTRICTED**
///   PayPal may allow slower funding sources.
enum PayPalPaymentMethodPreferenceV2 {
  /// Accept only payment methods that pay immediately (`IMMEDIATE_PAYMENT_REQUIRED`).
  immediatePaymentRequired,

  /// Accept any payment method the buyer has (`UNRESTRICTED`).
  unrestricted;

  /// Converts enum → PayPal API string.
  String get value {
    switch (this) {
      case PayPalPaymentMethodPreferenceV2.immediatePaymentRequired:
        return "IMMEDIATE_PAYMENT_REQUIRED";
      case PayPalPaymentMethodPreferenceV2.unrestricted:
        return "UNRESTRICTED";
    }
  }
}
