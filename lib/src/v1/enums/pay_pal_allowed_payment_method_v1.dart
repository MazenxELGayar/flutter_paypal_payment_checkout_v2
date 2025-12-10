/// "IMMEDIATE_PAYMENT_REQUIRED" or "UNRESTRICTED"
enum PayPalAllowedPaymentMethodV1 {
  unrestricted,
  instantFundingSource,
  immediatePay;

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
