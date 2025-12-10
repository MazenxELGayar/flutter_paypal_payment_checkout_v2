/// Represents the allowed payment methods for PayPal V1 Payments API.
///
/// These values define how PayPal should process the payer's funding source.
/// They map directly to the PayPal REST API field:
/// `application_context -> payment_method -> allowed_payment_method`
///
/// Options:
/// - **UNRESTRICTED**
///   PayPal will use any available funding source.
/// - **INSTANT_FUNDING_SOURCE**
///   Requires an instant payment method such as a credit/debit card.
/// - **IMMEDIATE_PAY**
///   Forces immediate payment with no delays (legacy value, still accepted).
///
/// Example PayPal JSON:
/// ```json
/// {
///   "application_context": {
///     "payment_method": {
///       "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
///     }
///   }
/// }
/// ```
enum PayPalAllowedPaymentMethodV1 {
  /// `"UNRESTRICTED"`
  unrestricted,

  /// `"INSTANT_FUNDING_SOURCE"`
  instantFundingSource,

  /// `"IMMEDIATE_PAY"`
  immediatePay;

  /// Returns the string value expected by the PayPal API.
  String get value {
    switch (this) {
      case PayPalAllowedPaymentMethodV1.unrestricted:
        return "UNRESTRICTED";
      case PayPalAllowedPaymentMethodV1.instantFundingSource:
        return "INSTANT_FUNDING_SOURCE";
      case PayPalAllowedPaymentMethodV1.immediatePay:
        return "IMMEDIATE_PAY";
    }
  }

  /// Converts a raw PayPal API string into the corresponding enum value.
  ///
  /// Defaults to [unrestricted] when the input is null or unrecognized.
  static PayPalAllowedPaymentMethodV1 fromString(String? value) {
    switch (value) {
      case "UNRESTRICTED":
        return PayPalAllowedPaymentMethodV1.unrestricted;
      case "INSTANT_FUNDING_SOURCE":
        return PayPalAllowedPaymentMethodV1.instantFundingSource;
      case "IMMEDIATE_PAY":
        return PayPalAllowedPaymentMethodV1.immediatePay;
      default:
        return PayPalAllowedPaymentMethodV1.unrestricted;
    }
  }
}
