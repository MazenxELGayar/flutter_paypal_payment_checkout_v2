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
  immediatePaymentRequired,
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
