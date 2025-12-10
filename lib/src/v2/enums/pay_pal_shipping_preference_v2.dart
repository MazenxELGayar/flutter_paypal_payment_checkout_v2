

/// PayPal Orders V2 `shipping_preference`
///
/// Controls how shipping addresses are handled during checkout.
enum PayPalShippingPreferenceV2 {
  /// Use the buyer’s saved PayPal address.
  getFromFile,

  /// No shipping address is needed (digital goods, subscriptions, services).
  noShipping,

  /// Use the address provided in the order payload.
  /// User cannot change it on PayPal.
  setProvidedAddress;

  /// Convert enum → API string
  String get value {
    switch (this) {
      case PayPalShippingPreferenceV2.getFromFile:
        return "GET_FROM_FILE";
      case PayPalShippingPreferenceV2.noShipping:
        return "NO_SHIPPING";
      case PayPalShippingPreferenceV2.setProvidedAddress:
        return "SET_PROVIDED_ADDRESS";
    }
  }

  /// Convert API string → enum
  static PayPalShippingPreferenceV2 fromString(String raw) {
    switch (raw) {
      case "GET_FROM_FILE":
        return PayPalShippingPreferenceV2.getFromFile;
      case "NO_SHIPPING":
        return PayPalShippingPreferenceV2.noShipping;
      case "SET_PROVIDED_ADDRESS":
        return PayPalShippingPreferenceV2.setProvidedAddress;
      default:
        throw ArgumentError("Invalid PayPalShippingPreference: $raw");
    }
  }
}
